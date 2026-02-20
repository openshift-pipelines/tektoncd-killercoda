#!/bin/bash
# Verify step 1: Dashboard is configured with external-logs flag
kubectl get deployment tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null | grep -q "external-logs"
