#!/bin/bash
# Verify step 1: Vault is running and secrets are stored
kubectl exec -n vault vault-0 -- vault kv get secret/pipeline/db 2>/dev/null | grep -q "username"
