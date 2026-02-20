#!/bin/bash
# Verify step 2: PipelineRun completed successfully
kubectl get pipelinerun build-and-test-run-1 -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"
