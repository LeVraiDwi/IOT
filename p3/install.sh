#!/bin/bash

echo "=== Installing Docker ==="
sudo apt update
sudo apt install -y docker.io curl
sudo usermod -aG docker $USER

echo "=== Installing K3d ==="
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

echo "=== Installing kubectl ==="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "=== Installing Argo CD CLI ==="
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

echo "=== Installing Git (if not present) ==="
sudo apt install -y git

echo "Installation complete! Please run: newgrp docker"
