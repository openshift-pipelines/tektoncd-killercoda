#!/bin/bash
# Background script: installs Tekton Pipelines, ArgoCD, tkn CLI, argocd CLI, and local Git repo
# Runs automatically when the scenario starts

set -e

# Wait for Kubernetes to be ready
while ! kubectl get nodes &>/dev/null; do
  sleep 2
done

# Install Tekton Pipelines v1.9.0
kubectl apply --filename https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.9.0/release.yaml

# Wait for Tekton Pipelines pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines \
  -n tekton-pipelines --timeout=120s

# Install ArgoCD core (pinned to v2.13.3 to match CLI version)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.3/manifests/core-install.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-application-controller \
  -n argocd --timeout=180s

# Install the Tekton CLI (tkn) - pinned version
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# Install argocd CLI - pinned version
ARGOCD_VERSION="2.13.3"
curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64"
chmod +x /usr/local/bin/argocd

# Ensure git uses 'master' as default branch (consistent across Git versions)
git config --global init.defaultBranch master

# Set up local bare Git repo for GitOps demo
git init --bare /opt/gitops-repo.git

# Start git daemon so pods (ArgoCD, Tekton) can access the repo over the network
nohup git daemon --reuseaddr --base-path=/opt --export-all \
  --enable=receive-pack --listen=0.0.0.0 /opt &>/dev/null &

# Save the node IP for use in tutorial steps
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "$NODE_IP" > /tmp/node-ip

echo "Tekton Pipelines, ArgoCD, and tools are ready!"
