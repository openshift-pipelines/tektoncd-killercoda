#!/bin/bash
# Background script: installs Tekton Pipelines, Dashboard, and tkn CLI
# Runs automatically when the scenario starts

set -e

# Wait for Kubernetes to be ready
while ! kubectl get nodes &>/dev/null; do
  sleep 2
done

# Install Tekton Pipelines (latest stable release)
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for Tekton Pipelines pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines \
  -n tekton-pipelines --timeout=120s

# Install the Tekton Dashboard (latest stable release)
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

# Wait for Dashboard pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-dashboard \
  -n tekton-pipelines --timeout=120s

# Install the Tekton CLI (tkn)
TKN_VERSION=$(curl -s https://api.github.com/repos/tektoncd/cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Dashboard, and tkn CLI are ready!"
