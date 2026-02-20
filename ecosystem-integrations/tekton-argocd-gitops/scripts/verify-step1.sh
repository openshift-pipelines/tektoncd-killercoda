#!/bin/bash
# Verify step 1: ArgoCD Application resource exists
kubectl get application demo-app -n argocd &>/dev/null
