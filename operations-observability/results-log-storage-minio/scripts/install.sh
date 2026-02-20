#!/bin/bash
# Background script: installs Tekton Pipelines v1.9.0, Tekton Results v0.18.0,
# MinIO via Helm, and tkn CLI v0.43.0
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

# ── 2. Create PostgreSQL secret for Results ──────────────────────────────────
kubectl create secret generic tekton-results-postgres \
  --namespace=tekton-pipelines \
  --from-literal=POSTGRES_USER=result \
  --from-literal=POSTGRES_PASSWORD=resultpassword

# ── 3. Generate self-signed TLS certificate ──────────────────────────────────
openssl req -x509 \
  -newkey rsa:4096 \
  -keyout /tmp/key.pem \
  -out /tmp/cert.pem \
  -days 365 \
  -nodes \
  -subj '/CN=tekton-results-api-service.tekton-pipelines.svc.cluster.local'

# ── 4. Create TLS secret for Results API ─────────────────────────────────────
kubectl create secret tls tekton-results-tls \
  --cert=/tmp/cert.pem \
  --key=/tmp/key.pem \
  -n tekton-pipelines

# ── 5. Install Tekton Results v0.18.0 ────────────────────────────────────────
kubectl apply -f https://infra.tekton.dev/tekton-releases/results/previous/v0.18.0/release.yaml

# ── 6. Wait for Results pods to be ready ─────────────────────────────────────
sleep 10
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-results \
  -n tekton-pipelines --timeout=180s

# ── 7. Install Helm ──────────────────────────────────────────────────────────
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ── 8. Install MinIO via Helm ────────────────────────────────────────────────
helm repo add minio https://charts.min.io/
helm repo update
helm install minio minio/minio \
  --set mode=standalone \
  --set replicas=1 \
  --set persistence.enabled=false \
  --set resources.requests.memory=256Mi \
  --set rootUser=minioadmin \
  --set rootPassword=minioadmin \
  -n minio --create-namespace

# Wait for MinIO pod to be ready
kubectl wait --for=condition=ready pod -l app=minio \
  -n minio --timeout=180s

# ── 9. Install tkn CLI (pinned v0.43.0) ─────────────────────────────────────
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# ── 10. Install MinIO client (mc) for browsing ──────────────────────────────
curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc /usr/local/bin/

echo "Tekton Pipelines, Results, MinIO, and tkn CLI are ready!"
