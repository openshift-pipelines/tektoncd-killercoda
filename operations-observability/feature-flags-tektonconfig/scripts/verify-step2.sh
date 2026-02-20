#!/bin/bash
# Verify step 2: Beta features enabled
API_FIELDS=$(kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.enable-api-fields}' 2>/dev/null)
[ "$API_FIELDS" = "beta" ]
