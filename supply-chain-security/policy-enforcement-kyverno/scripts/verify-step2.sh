#!/bin/bash
# Verify step 2: ClusterPolicy exists
kubectl get clusterpolicy verify-image-signatures -o name 2>/dev/null | grep -q "clusterpolicy.kyverno.io/verify-image-signatures"
