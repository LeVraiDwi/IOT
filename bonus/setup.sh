#!/bin/bash

# ============================================================
# Complete Setup: K3D + ArgoCD + GitLab (ClusterIP)
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Complete Setup with Internal GitLab ===${NC}"

# Variables
CLUSTER_NAME="iot-cluster"
REPO_NAME="iot-argocd"
MANIFESTS_DIR="manifests"  # folder containing deployment.yaml, service.yaml
GITLAB_NAMESPACE="gitlab"

# --- Check tools ---
echo -e "${YELLOW}Checking required tools...${NC}"
for bin in docker k3d kubectl helm argocd git curl jq; do
  if ! command -v $bin &>/dev/null; then
    echo -e "${RED}$bin not found. Please install it first.${NC}"
    exit 1
  fi
done

# --- Create K3D cluster ---
echo -e "${YELLOW}Creating K3D cluster...${NC}"
k3d cluster delete $CLUSTER_NAME &>/dev/null || true
k3d cluster create $CLUSTER_NAME --agents 2
sleep 10
kubectl get nodes

# --- Install ArgoCD ---
echo -e "${YELLOW}Installing ArgoCD...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# --- Create dev namespace ---
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# --- Get ArgoCD password ---
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "$ARGOCD_PASS" > argocd-password.txt
echo -e "${GREEN}ArgoCD password saved to argocd-password.txt${NC}"

# --- Port forward ArgoCD for UI access ---
kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
sleep 5
argocd login localhost:8090 --username admin --password "$ARGOCD_PASS" --insecure

# ============================================================
# GitLab Installation (ClusterIP)
# ============================================================
echo -e "${YELLOW}Installing GitLab...${NC}"
kubectl create namespace $GITLAB_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

helm repo add gitlab https://charts.gitlab.io/ || true
helm repo update

# Assumes gitlab-values.yaml exists and sets webservice.type=ClusterIP
helm upgrade --install gitlab gitlab/gitlab \
  --namespace $GITLAB_NAMESPACE \
  --timeout 600s \
  -f gitlab-values.yaml

# --- Wait for GitLab webservice ---
echo "Waiting for GitLab webservice to be ready..."
kubectl rollout status deployment/$(kubectl get deploy -n $GITLAB_NAMESPACE -o name | grep gitlab-webservice) \
  -n $GITLAB_NAMESPACE --timeout=600s

# --- Get GitLab root password ---
GITLAB_PASS=$(kubectl get secret -n $GITLAB_NAMESPACE $(kubectl get secret -n $GITLAB_NAMESPACE | grep "gitlab-initial-root-password" | awk '{print $1}') \
  -o jsonpath="{.data.password}" | base64 -d)
echo "$GITLAB_PASS" > gitlab-root-password.txt
echo -e "${GREEN}GitLab root password saved to gitlab-root-password.txt${NC}"

# ============================================================
# Create GitLab project via API
# ============================================================
GITLAB_API="http://gitlab.$GITLAB_NAMESPACE.svc.cluster.local/api/v4"

# Wait until API responds
echo "Waiting for GitLab API to be ready..."
until curl -s --header "PRIVATE-TOKEN: $GITLAB_PASS" "$GITLAB_API/version" >/dev/null 2>&1; do
  echo "GitLab API not ready yet, waiting 5s..."
  sleep 5
done

# Create project if it doesn't exist
PROJECT_CHECK=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_PASS" "$GITLAB_API/projects/root%2F$REPO_NAME")
if [[ "$PROJECT_CHECK" == *"Not Found"* || -z "$PROJECT_CHECK" ]]; then
  echo "Creating GitLab project $REPO_NAME..."
  curl -s --request POST --header "PRIVATE-TOKEN: $GITLAB_PASS" \
    --header "Content-Type: application/json" \
    --data "{\"name\": \"$REPO_NAME\", \"visibility\": \"private\"}" \
    "$GITLAB_API/projects"
else
  echo "GitLab project $REPO_NAME already exists. Skipping creation."
fi

# --- Push manifests to GitLab ---
if [ -d "$MANIFESTS_DIR" ]; then
  cd $MANIFESTS_DIR
  git init
  git add .
  git commit -m "Initial commit with Kubernetes manifests"
  
  # Use ClusterIP service name (internal DNS) to push
  git remote add origin http://root:$GITLAB_PASS@gitlab.$GITLAB_NAMESPACE.svc.cluster.local/root/$REPO_NAME.git

  git push -u origin main
  cd ..
else
  echo -e "${RED}Directory $MANIFESTS_DIR not found!${NC}"
fi

# ============================================================
# Register GitLab repo in ArgoCD (internal DNS)
# ============================================================
echo -e "${YELLOW}Registering GitLab repo in ArgoCD...${NC}"
argocd repo add http://gitlab.$GITLAB_NAMESPACE.svc.cluster.local/root/$REPO_NAME.git \
  --username root \
  --password "$GITLAB_PASS" \
  --insecure

# --- Create ArgoCD application ---
echo -e "${YELLOW}Creating ArgoCD application...${NC}"
argocd app create wil-app \
  --repo http://gitlab.$GITLAB_NAMESPACE.svc.cluster.local/root/$REPO_NAME.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal \
  --upsert

# --- Sync application ---
echo -e "${YELLOW}Syncing application...${NC}"
argocd app sync wil-app

# --- Final info ---
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo "ArgoCD UI: http://localhost:8090"
echo "ArgoCD Username: admin"
echo "ArgoCD Password: $ARGOCD_PASS"
echo "GitLab root password: $GITLAB_PASS"
echo "Application URL: http://localhost:8888"
