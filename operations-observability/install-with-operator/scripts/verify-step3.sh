#!/bin/bash
# Verify step 3: TektonConfig has pipeline configuration
kubectl get tektonconfig config -o jsonpath='{.spec.pipeline}' 2>/dev/null | grep -q .
