#!/bin/bash
# Background script: installs Tekton Pipelines, Dashboard, and tkn CLI
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

# Install the Tekton Dashboard in read-write mode (allows creating resources from UI)
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/latest/release-full.yaml

# Wait for Dashboard pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-dashboard \
  -n tekton-pipelines --timeout=120s

# Install the Tekton CLI (tkn)
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Dashboard, and tkn CLI are ready!"
