kubectl delete pods --all --all-namespaces
kubectl delete namespace argocd dev gitlab
k3d cluster delete iot-cluster
# Remove dangling images
docker image prune -af

# Remove unused volumes
docker volume prune -f
