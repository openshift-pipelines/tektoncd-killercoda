#!/bin/bash
# Verify step 3: Vault Transit key exists and Chains KMS config is set
kubectl exec -n vault vault-0 -- vault read transit/keys/tekton-chains &>/dev/null && \
KMS_REF=$(kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.signers\.kms\.kmsref}' 2>/dev/null)
[ -n "$KMS_REF" ]
