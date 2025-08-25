My GitHub account have repository containing:
namespace.yaml
deployment.yaml (with wil42/playground:v1)
service.yaml

What is argoCD : ArgoCD is a tool that automatically deploys your applications to Kubernetes by watching your GitHub repository for changes.

Quick Start
1. Installation

    ./install.sh
    newgrp docker  # Activate Docker group


2. Setup Everything

    ./setup.sh

This script does:

Creates K3d cluster
Installs Argo CD
Configures port forwarding (8090)
Deploys your application automatically


3. Test


./test.sh
Verifies all components are running correctly.


Argo CD UI : http://localhost:8090
Application : http://localhost:8888 -> No auth required

Testing Version Update (v1 → v2)

cd ~/IoT-project/p3/lbesnard-iot-project

    # Update to v2
    sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment.yaml
    git add deployment.yaml && git commit -m "Update to v2" && git push

    # Wait 60 seconds for ArgoCD to sync
    sleep 60

    # Verify update
    curl http://localhost:8888/  # Should show v2

Summary: 
Two namespaces -> argocd and dev
ArgoCD syncs from GitHub automatically
Application accessible on port 8888
Can update version via Git push
No manual deployment needed


Notes
Port 8080 is used by K3d loadbalancer (not available)
Port 8090 is ArgoCD UI
Port 8888 is your application
