#!/bin/bash
# Background script: installs Tekton Pipelines v1.9.0, tkn CLI v0.43.0,
# and a local OCI registry for Tekton Bundles
# Runs automatically when the scenario starts

set -e

# Wait for Kubernetes to be ready
while ! kubectl get nodes &>/dev/null; do
  sleep 2
done

# ── 1. Install Tekton Pipelines v1.9.0 ──────────────────────────────────────
kubectl apply --filename https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.9.0/release.yaml

kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines \
  -n tekton-pipelines --timeout=120s

# ── 2. Install tkn CLI (pinned v0.43.0) ─────────────────────────────────────
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# ── 3. Start a local OCI registry ───────────────────────────────────────────
docker run -d -p 5000:5000 --name registry registry:2

# Wait for the registry to be ready
sleep 5
until curl -s http://localhost:5000/v2/ &>/dev/null; do
  sleep 2
done

echo "Tekton Pipelines, tkn CLI, and local registry are ready!"
