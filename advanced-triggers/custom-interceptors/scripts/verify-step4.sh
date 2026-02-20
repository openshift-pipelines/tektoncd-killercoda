#!/bin/bash
# Verify step 4: A PipelineRun was created from the interceptor-triggered event
kubectl get pipelinerun -o name 2>/dev/null | grep -q pipelinerun
