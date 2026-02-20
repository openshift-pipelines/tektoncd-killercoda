#!/bin/bash
# Verify step 2: TektonConfig has a valid profile set
kubectl get tektonconfig config -o jsonpath='{.spec.profile}' 2>/dev/null | grep -qE '(all|lite|basic)'
