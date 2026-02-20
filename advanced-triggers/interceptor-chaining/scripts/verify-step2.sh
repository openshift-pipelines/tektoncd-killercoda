#!/bin/bash
# Verify step 2: github-chain EventListener exists
kubectl get eventlistener github-chain -o name 2>/dev/null | grep -q "eventlistener.triggers.tekton.dev/github-chain" && \
kubectl get secret github-webhook-secret -o name 2>/dev/null | grep -q "secret/github-webhook-secret"
