#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Part 3: K3d and Argo CD Demo ===${NC}\n"

echo -e "${YELLOW}1. Checking K3d cluster:${NC}"
kubectl get nodes
echo ""

echo -e "${YELLOW}2. Checking namespaces:${NC}"
kubectl get ns | grep -E "NAME|argocd|dev"
echo ""

echo -e "${YELLOW}3. Checking Argo CD pods:${NC}"
kubectl get pods -n argocd | head -5
echo ""

echo -e "${YELLOW}4. Checking application in dev namespace:${NC}"
kubectl get pods -n dev
echo ""

echo -e "${YELLOW}5. Testing application (current version):${NC}"
curl http://localhost:8888/
echo -e "\n"

echo -e "${YELLOW}6. Checking Argo CD applications:${NC}"
argocd app list
echo ""

echo -e "${YELLOW}7. Getting Argo CD password:${NC}"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo -e "\n\n"

echo -e "${GREEN}Argo CD UI available at: http://localhost:8080${NC}"
