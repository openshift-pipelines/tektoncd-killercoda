#!/bin/bash
# Verify step 2: A TaskRun exists (signed by Chains via Vault KMS)
kubectl get taskrun -l tekton.dev/task=vault-signed-build -o name 2>/dev/null | grep -q taskrun
