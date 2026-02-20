#!/bin/bash
# Verify step 1: The 'log-message' StepAction exists
kubectl get stepaction log-message &>/dev/null
