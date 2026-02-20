#!/bin/bash
# Verify step 1: Pipeline and Task exist
kubectl get pipeline interceptor-demo &>/dev/null && kubectl get task echo-event &>/dev/null
