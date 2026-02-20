#!/bin/bash
# Verify step 2: All three Tasks and the Pipeline exist
kubectl get task clone-repo -o name 2>/dev/null | grep -q "task.tekton.dev/clone-repo" && \
kubectl get task build-and-push -o name 2>/dev/null | grep -q "task.tekton.dev/build-and-push" && \
kubectl get task verify-signature -o name 2>/dev/null | grep -q "task.tekton.dev/verify-signature" && \
kubectl get pipeline secure-build-pipeline -o name 2>/dev/null | grep -q "pipeline.tekton.dev/secure-build-pipeline"
