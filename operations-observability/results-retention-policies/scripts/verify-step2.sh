#!/bin/bash
# Verify step 2: Retention ConfigMap exists
kubectl get configmap tekton-results-retention -n tekton-pipelines &>/dev/null
