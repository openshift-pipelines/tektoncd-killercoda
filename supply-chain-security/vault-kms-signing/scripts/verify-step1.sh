#!/bin/bash
# Verify step 1: Vault Transit key 'tekton-chains' exists
kubectl exec -n vault vault-0 -- vault read transit/keys/tekton-chains &>/dev/null
