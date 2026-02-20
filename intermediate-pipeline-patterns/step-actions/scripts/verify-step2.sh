#!/bin/bash
# Verify step 2: At least 2 Tasks with label tutorial=step-actions exist
kubectl get task -l tutorial=step-actions --no-headers 2>/dev/null | wc -l | grep -q '[2-9]'
