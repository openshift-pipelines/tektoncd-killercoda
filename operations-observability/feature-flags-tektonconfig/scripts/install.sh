#!/bin/bash
# Background script: installs Tekton Operator and tkn CLI
# Runs automatically when the scenario starts

set -e

# Wait for Kubernetes to be ready
while ! kubectl get nodes &>/dev/null; do
  sleep 2
done

# Install Tekton Operator v0.76.0
kubectl apply -f https://infra.tekton.dev/tekton-releases/operator/previous/v0.76.0/release.yaml

# Wait for Tekton Operator pods to be ready
kubectl wait --for=condition=ready pod -l app=tekton-operator \
  -n tekton-operator --timeout=180s

# Wait for Tekton Pipelines to be installed by the Operator
sleep 15
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines \
  -n tekton-pipelines --timeout=180s 2>/dev/null || true

# Install the Tekton CLI (tkn) - pinned version
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Operator and tkn CLI are ready!"
