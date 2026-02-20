#!/bin/bash
# Verify step 1: Chains is configured with transparency enabled
TRANSPARENCY=$(kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.transparency\.enabled}' 2>/dev/null)
[ "$TRANSPARENCY" = "true" ]
