#!/bin/bash
# Verify step 2: Vault Pipeline run completed
kubectl get pipelinerun vault-pipeline-run -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"
