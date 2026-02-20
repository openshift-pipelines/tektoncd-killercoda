#!/bin/bash
# Verify step 2: At least one PipelineRun exists
kubectl get pipelinerun --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
