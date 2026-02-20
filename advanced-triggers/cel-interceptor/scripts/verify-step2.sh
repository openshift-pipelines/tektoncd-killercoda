#!/bin/bash
# Verify step 2: At least one PipelineRun was created by the EventListener
kubectl get pipelinerun -l triggers.tekton.dev/eventlistener=cel-demo --no-headers 2>/dev/null \
  | wc -l | grep -q '[1-9]'
