#!/bin/bash
# Verify step 3: Retention configuration is in place
kubectl get configmap tekton-results-retention -n tekton-pipelines &>/dev/null
