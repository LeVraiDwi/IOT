#!/bin/bash
# Kill any existing port-forward
pkill -f "port-forward.*8090" 2>/dev/null
# Start new port-forward
kubectl port-forward svc/argocd-server -n argocd 8090:443 > /dev/null 2>&1 &
echo "Port forward restarted on port 8090"
