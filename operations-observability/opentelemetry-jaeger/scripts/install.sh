#!/bin/bash
# Background script: installs Tekton Pipelines, Jaeger all-in-one, and tkn CLI
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

# ── 2. Install Jaeger all-in-one ─────────────────────────────────────────────
cat <<EOF | kubectl apply -n tekton-pipelines -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  labels:
    app: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
        - name: jaeger
          image: jaegertracing/all-in-one:1.53
          ports:
            - containerPort: 16686
              name: ui
            - containerPort: 14268
              name: collector
          env:
            - name: COLLECTOR_OTLP_ENABLED
              value: "true"
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector
spec:
  selector:
    app: jaeger
  ports:
    - port: 14268
      targetPort: 14268
      name: collector
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-query
spec:
  selector:
    app: jaeger
  ports:
    - port: 16686
      targetPort: 16686
      name: ui
EOF

kubectl wait --for=condition=available deployment/jaeger -n tekton-pipelines --timeout=120s

# ── 3. Install tkn CLI (pinned v0.43.0) ─────────────────────────────────────
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Jaeger, and tkn CLI are ready!"
