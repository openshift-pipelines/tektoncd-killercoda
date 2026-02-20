#!/bin/bash
# Verify step 1: Pipeline and Task exist
kubectl get pipeline ci-pipeline &>/dev/null && kubectl get task log-commit &>/dev/null
