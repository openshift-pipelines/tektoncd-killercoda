#!/bin/bash
# Verify step 2: The gitops-ci Pipeline exists (step 2 creates the Pipeline)
kubectl get pipeline matrix-include-demo &>/dev/null
