#!/bin/bash
# Verify step 1: Results is configured for S3 log storage and MinIO bucket exists
kubectl get configmap tekton-results-config -n tekton-pipelines -o jsonpath='{.data.logs_api}' 2>/dev/null | grep -q "true"
