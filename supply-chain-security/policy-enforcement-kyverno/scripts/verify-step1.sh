#!/bin/bash
# Verify step 1: Chains configured, Kyverno running, secure-deployments namespace exists
kubectl get secret signing-secrets -n tekton-chains &>/dev/null && \
kubectl get pods -n kyverno -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q "Running" && \
kubectl get namespace secure-deployments &>/dev/null
