#!/bin/bash
# Verify step 3: Transparency configuration is in place
TRANSPARENCY=$(kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.transparency\.enabled}' 2>/dev/null)
[ "$TRANSPARENCY" = "true" ]
