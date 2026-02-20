#!/bin/bash
# Verify step 2: The 'gitops-ci' Pipeline exists
kubectl get pipeline gitops-ci &>/dev/null
