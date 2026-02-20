#!/bin/bash
# Verify step 2: PipelineRun completed and Results captured it
kubectl get results.results.tekton.dev -n default --no-headers 2>/dev/null | grep -q .
