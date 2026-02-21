#!/bin/bash
# Background script: installs Tekton Pipelines and tkn CLI
set -e
while ! kubectl get nodes &>/dev/null; do sleep 2; done

kubectl apply --filename https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.9.0/release.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines -n tekton-pipelines --timeout=120s

TKN_VERSION="0.43.0"
curl -LO "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
tar xvzf "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn
rm -f "tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"

# Install tkn-pac plugin
PAC_VERSION="0.27.1"
curl -LO "https://github.com/openshift-pipelines/pipelines-as-code/releases/download/v${PAC_VERSION}/tkn-pac_${PAC_VERSION}_Linux_x86_64.tar.gz" 2>/dev/null && \
  tar xvzf "tkn-pac_${PAC_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin/ tkn-pac 2>/dev/null && \
  rm -f "tkn-pac_${PAC_VERSION}_Linux_x86_64.tar.gz" || echo "tkn-pac install skipped"

echo "Tekton Pipelines and tkn CLI are ready!"
