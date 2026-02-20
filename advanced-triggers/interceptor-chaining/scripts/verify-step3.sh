#!/bin/bash
# Verify step 3: production-chain EventListener exists and PipelineRuns were created
kubectl get eventlistener production-chain -o name 2>/dev/null | grep -q "eventlistener.triggers.tekton.dev/production-chain" && \
kubectl get pipelinerun -o name 2>/dev/null | grep -q "production-run"
