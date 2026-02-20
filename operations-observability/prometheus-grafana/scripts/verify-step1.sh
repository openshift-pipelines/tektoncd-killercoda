#!/bin/bash
# Verify step 1: The metrics-demo Task exists and has been run
kubectl get task metrics-demo &>/dev/null
