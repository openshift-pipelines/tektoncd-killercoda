#!/bin/bash
# Verify step 3: Operational settings applied
RESULTS_FROM=$(kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.results-from}' 2>/dev/null)
[ "$RESULTS_FROM" = "sidecar-logs" ]
