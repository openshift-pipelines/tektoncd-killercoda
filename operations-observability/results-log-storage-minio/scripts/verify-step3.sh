#!/bin/bash
# Verify step 3: Multiple PipelineRuns completed and results are stored
kubectl get pipelinerun build-and-test-run-3 -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"
