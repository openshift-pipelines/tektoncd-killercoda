#!/bin/bash
# Verify step 1: Chains configured, signing-secrets exist, source repo created
kubectl get secret signing-secrets -n tekton-chains &>/dev/null && \
test -f /root/source-repo/Dockerfile
