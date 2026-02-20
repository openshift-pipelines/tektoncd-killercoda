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

# Install ArgoCD (core, lightweight)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
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

# Set up local bare Git repo for GitOps demo
git init --bare /opt/gitops-repo.git

echo "Tekton Pipelines, ArgoCD, and tools are ready!"
