#!/bin/bash
# Verify step 1: chain-demo EventListener exists and is ready
kubectl get eventlistener chain-demo -o name 2>/dev/null | grep -q "eventlistener.triggers.tekton.dev/chain-demo" && \
kubectl get pipeline interceptor-chain-demo -o name 2>/dev/null | grep -q "pipeline.tekton.dev/interceptor-chain-demo"
