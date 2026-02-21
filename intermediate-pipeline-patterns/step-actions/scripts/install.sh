#!/bin/bash
# Background script: installs Tekton Pipelines and tkn CLI
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

# Enable beta API fields (required for v1beta1 StepActions)
kubectl patch configmap feature-flags -n tekton-pipelines \
  -p '{"data":{"enable-api-fields":"beta"}}'

# Restart the controller to pick up the config change
kubectl delete pod -l app=tekton-pipelines-controller -n tekton-pipelines
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=120s

# Install the Tekton CLI (tkn)
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines and tkn CLI are ready!"
