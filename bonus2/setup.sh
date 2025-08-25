#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Complete Part 3 Setup from Fresh VM ===${NC}"

# CHANGE THESE VARIABLES BEFORE CORRECTION
GITHUB_USER="leobesnard"
REPO_NAME="lbesnard-iot-argocd"

# Step 1: Check if tools are installed
echo -e "${YELLOW}Checking required tools...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please run install.sh first and then: newgrp docker"
    exit 1
fi

if ! command -v k3d &> /dev/null; then
    echo "k3d not found. Please run install.sh first"
    exit 1
fi

# Step 2: Create K3d cluster
echo -e "${YELLOW}Creating K3d cluster...${NC}"
k3d cluster create iot-cluster --port "8888:30080@agent:0" -p "8080:80@loadbalancer" --agents 2

# Wait for cluster to be ready
sleep 10
kubectl get nodes

# Step 3: Install Argo CD
echo -e "${YELLOW}Installing Argo CD...${NC}"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD pods to be ready (this takes 1-2 minutes)..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Step 4: Create dev namespace
echo -e "${YELLOW}Creating dev namespace...${NC}"
kubectl create namespace dev

# Step 5: Get Argo CD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}Argo CD Password: $ARGOCD_PASSWORD${NC}"
echo "$ARGOCD_PASSWORD" > argocd-password.txt
echo "Password saved to argocd-password.txt"

# Step 6: Start port forward
echo -e "${YELLOW}Starting Argo CD port forward on port 8090...${NC}"
kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
PORTFORWARD_PID=$!
echo "Port forward started with PID: $PORTFORWARD_PID"
sleep 5

# Check if port forward is working
if ! nc -z localhost 8090 2>/dev/null; then
    echo -e "${RED}Port forward failed to start. Trying again...${NC}"
    kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
    sleep 5
fi

# Step 7: Login to Argo CD
echo -e "${YELLOW}Logging into Argo CD...${NC}"
argocd login localhost:8090 --username admin --password $ARGOCD_PASSWORD --insecure

# Step 8: Create Argo CD application
echo -e "${YELLOW}Creating Argo CD application...${NC}"
argocd app create wil-app \
  --repo https://github.com/$GITHUB_USER/$REPO_NAME \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Step 9: Sync application
echo -e "${YELLOW}Syncing application...${NC}"
argocd app sync wil-app

# Step 10: Wait for deployment
echo -e "${YELLOW}Waiting for application to deploy (30 seconds)...${NC}"
sleep 30

# Step 11: Create a script to restart port-forward if needed
cat > restart-portforward.sh << 'SCRIPT'
#!/bin/bash
# Kill any existing port-forward
pkill -f "port-forward.*8090" 2>/dev/null
# Start new port-forward
kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
echo "Port forward restarted on port 8090"
SCRIPT
chmod +x restart-portforward.sh

# Step 12: Verify everything
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "${YELLOW}Namespaces:${NC}"
kubectl get ns | grep -E "argocd|dev"

echo -e "${YELLOW}Application pods:${NC}"
kubectl get pods -n dev

echo -e "${YELLOW}Testing application:${NC}"
curl http://localhost:8888/

echo -e "${GREEN}=== Access Information ===${NC}"
echo "Argo CD UI: http://localhost:8090"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo "Application: http://localhost:8888"
echo ""
echo -e "${YELLOW}=== Useful Commands ===${NC}"
echo "If port forward stops working, run: ./restart-portforward.sh"
echo "To check ArgoCD apps: argocd app list"
echo "To test the app: curl http://localhost:8888/"
echo "To see ArgoCD password again: cat argocd-password.txt"
