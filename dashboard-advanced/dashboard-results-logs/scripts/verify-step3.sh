#!/bin/bash
# Verify step 3: PipelineRuns were pruned but Results still has data
# The ci-pipeline PipelineRuns should be deleted from Kubernetes
# but Results should still have records
kubectl get results.results.tekton.dev -n default --no-headers 2>/dev/null | wc -l | grep -qv "^0$"
