#!/bin/bash
# Verify step 1: git-clone Task is installed
kubectl get task git-clone -o name 2>/dev/null | grep -q "task.tekton.dev/git-clone"
