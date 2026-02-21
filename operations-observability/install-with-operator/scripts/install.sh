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

# Wait for TektonConfig to become ready (Operator v0.76.0 can take >5 min)
echo "Waiting for TektonConfig to become ready..."
for i in $(seq 1 60); do
  READY=$(kubectl get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
  if [[ "$READY" == "True" ]]; then
    echo "TektonConfig is ready (attempt $i/60)"
    break
  fi
  if [[ "$i" -eq 60 ]]; then
    echo "WARNING: TektonConfig not ready after 5 minutes"
  fi
  echo "Waiting for TektonConfig... (status=$READY, attempt $i/60)"
  sleep 5
done

# Install the Tekton CLI (tkn) - pinned version
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Operator and tkn CLI are ready!"
