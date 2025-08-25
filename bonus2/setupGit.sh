kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab --timeout 600s -f gitlab-values.yaml
kubectl get secret -n gitlab gitlab-gitlab-initial-root-password   -o jsonpath="{.data.password}" | base64 -d