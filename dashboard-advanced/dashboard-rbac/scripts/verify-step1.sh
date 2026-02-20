#!/bin/bash
# Verify step 1: Dashboard is running in read-write mode
kubectl get deployment tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null | grep -qv "read-only=true"
