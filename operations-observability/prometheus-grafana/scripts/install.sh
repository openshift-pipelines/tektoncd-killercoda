#!/bin/bash
# Background script: installs Tekton Pipelines v1.9.0, tkn CLI v0.43.0,
# Prometheus, and Grafana via Helm
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

# ── 3. Install Helm ─────────────────────────────────────────────────────────
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ── 4. Install Prometheus (minimal, no persistent storage) ───────────────────
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus \
  --set server.persistentVolume.enabled=false \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false \
  -n monitoring --create-namespace

# ── 5. Install Grafana (no persistent storage, admin/admin) ──────────────────
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana \
  --set persistence.enabled=false \
  --set adminPassword=admin \
  -n monitoring

# ── 6. Wait for monitoring pods to be ready ──────────────────────────────────
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus \
  -n monitoring --timeout=180s

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana \
  -n monitoring --timeout=180s

echo "Tekton Pipelines, Prometheus, Grafana, and tkn CLI are ready!"
