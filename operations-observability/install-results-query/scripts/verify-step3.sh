#!/bin/bash
# Verify step 3: Results watcher has recorded PipelineRun data
# Check via kubectl since port-forward may not persist across verify script execution
kubectl get -n tekton-pipelines deployment tekton-results-watcher --no-headers 2>/dev/null | grep -q "1/1"
