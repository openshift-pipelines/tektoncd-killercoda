#!/bin/bash
# Verify step 2: TektonConfig is Ready after profile changes
kubectl get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q True
