#!/bin/bash
# Verify step 3: Admin TaskRun succeeded in team-alpha namespace
kubectl get taskrun team-task-run-admin -n team-alpha -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"
