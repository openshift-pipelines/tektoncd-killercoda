#!/bin/bash
# Background script: installs Tekton Pipelines, Tekton Triggers, and tkn CLI
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

# Install Tekton Triggers v0.34.0
kubectl apply --filename https://infra.tekton.dev/tekton-releases/triggers/previous/v0.34.0/release.yaml
kubectl apply --filename https://infra.tekton.dev/tekton-releases/triggers/previous/v0.34.0/interceptors.yaml

# Wait for Tekton Triggers pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-triggers \
  -n tekton-pipelines --timeout=120s

# Install the Tekton CLI (tkn)
TKN_VERSION=$(curl -s https://api.github.com/repos/tektoncd/cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Triggers, and tkn are ready!"
