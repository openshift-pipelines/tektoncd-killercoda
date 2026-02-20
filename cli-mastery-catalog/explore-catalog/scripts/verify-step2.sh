#!/bin/bash
# Verify step 2: kaniko Task is installed and clone-and-build Pipeline exists
kubectl get task kaniko -o name 2>/dev/null | grep -q "task.tekton.dev/kaniko" && \
kubectl get pipeline clone-and-build -o name 2>/dev/null | grep -q "pipeline.tekton.dev/clone-and-build"
