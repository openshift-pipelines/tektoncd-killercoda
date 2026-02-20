#!/bin/bash
# Background script: installs Tekton Pipelines v1.9.0, Dashboard (read-write),
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

# ── 2. Install Tekton Dashboard (read-write / full mode) ────────────────────
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.52.0/release-full.yaml

kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-dashboard \
  -n tekton-pipelines --timeout=120s

# ── 3. Install tkn CLI (pinned v0.43.0) ─────────────────────────────────────
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# ── 4. Create sample resources for testing ───────────────────────────────────
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello-dashboard
spec:
  steps:
    - name: hello
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Hello from Dashboard RBAC tutorial!"
EOF

echo "Tekton Pipelines, Dashboard, and tkn CLI are ready!"
