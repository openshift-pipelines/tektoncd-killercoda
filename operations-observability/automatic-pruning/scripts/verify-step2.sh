#!/bin/bash
# Verify step 2: TektonConfig has pruner schedule configured
kubectl get tektonconfig config -o jsonpath='{.spec.pruner}' 2>/dev/null | grep -q "schedule"
