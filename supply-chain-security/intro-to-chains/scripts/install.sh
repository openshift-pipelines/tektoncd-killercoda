#!/bin/bash
# Background script: installs Tekton Pipelines, Tekton Chains, tkn CLI, and cosign
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

# Install Tekton Chains v0.26.0
kubectl apply --filename https://infra.tekton.dev/tekton-releases/chains/previous/v0.26.0/release.yaml

# Wait for Tekton Chains pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=120s

# Install the Tekton CLI (tkn)
TKN_VERSION=$(curl -s https://api.github.com/repos/tektoncd/cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# Install cosign
COSIGN_VERSION=$(curl -s https://api.github.com/repos/sigstore/cosign/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -LO "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64"
chmod +x cosign-linux-amd64 && mv cosign-linux-amd64 /usr/local/bin/cosign

echo "Tekton Pipelines, Chains, tkn, and cosign are ready!"
