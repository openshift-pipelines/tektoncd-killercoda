#!/bin/bash
# Background script: installs Tekton Pipelines v1.9.0, HashiCorp Vault (dev mode),
# and tkn CLI v0.43.0
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

# ── 2. Install Helm ──────────────────────────────────────────────────────────
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ── 3. Install HashiCorp Vault via Helm (dev mode) ──────────────────────────
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
  --set server.dev.enabled=true \
  --set server.dev.devRootToken=root \
  --set injector.enabled=true \
  -n vault --create-namespace

# Wait for Vault pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault \
  -n vault --timeout=180s

# Wait for the injector to be ready
kubectl wait --for=condition=ready pod -l component=webhook -l app.kubernetes.io/name=vault-agent-injector \
  -n vault --timeout=180s

# ── 4. Install tkn CLI (pinned v0.43.0) ─────────────────────────────────────
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Vault, and tkn CLI are ready!"
