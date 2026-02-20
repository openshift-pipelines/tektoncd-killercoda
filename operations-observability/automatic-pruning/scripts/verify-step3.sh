#!/bin/bash
# Verify step 3: TektonConfig has pruner keep value configured
kubectl get tektonconfig config -o jsonpath='{.spec.pruner.keep}' 2>/dev/null | grep -q .
