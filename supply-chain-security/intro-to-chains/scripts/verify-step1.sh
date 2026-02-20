#!/bin/bash
# Verify step 1: signing-secrets Secret exists in tekton-chains namespace
kubectl get secret signing-secrets -n tekton-chains &>/dev/null
