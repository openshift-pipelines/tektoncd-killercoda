#!/bin/bash
# Background script: installs Tekton Operator, waits for Pipelines, and generates sample TaskRuns
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

# Wait for TektonConfig to be Ready (covers all installed components)
echo "Waiting for TektonConfig to be Ready..."
for i in $(seq 1 120); do
  STATUS=$(kubectl get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  if [ "$STATUS" = "True" ]; then
    echo "TektonConfig is Ready."
    break
  fi
  sleep 3
done

# Install the Tekton CLI (tkn) - pinned version
TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# Create sample Task and generate 10 TaskRuns for pruning demo
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: sample-task
spec:
  steps:
    - name: echo
      image: alpine
      script: echo "Sample run"
EOF

for i in $(seq 1 10); do
  kubectl create -f - <<EOF
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: sample-run-
spec:
  taskRef:
    name: sample-task
EOF
  sleep 1
done

# Wait for all TaskRuns to complete
echo "Waiting for TaskRuns to complete..."
for i in $(seq 1 60); do
  RUNNING=$(kubectl get taskrun --no-headers 2>/dev/null | grep -c "Running\|Pending" || true)
  if [ "$RUNNING" -eq 0 ]; then
    break
  fi
  sleep 2
done

echo "Tekton Operator with sample runs ready!"
