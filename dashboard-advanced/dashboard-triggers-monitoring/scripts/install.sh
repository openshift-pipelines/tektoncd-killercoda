#!/bin/bash
# Background script: installs Tekton Pipelines, Dashboard, Triggers, and tkn CLI
set -e
while ! kubectl get nodes &>/dev/null; do sleep 2; done

kubectl apply --filename https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.9.0/release.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines -n tekton-pipelines --timeout=120s

kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.52.0/release-full.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-dashboard -n tekton-pipelines --timeout=120s

kubectl apply --filename https://infra.tekton.dev/tekton-releases/triggers/previous/v0.34.0/release.yaml
kubectl apply --filename https://infra.tekton.dev/tekton-releases/triggers/previous/v0.34.0/interceptors.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-triggers -n tekton-pipelines --timeout=120s

TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

echo "Tekton Pipelines, Dashboard, Triggers, and tkn CLI are ready!"
