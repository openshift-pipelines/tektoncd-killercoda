#!/bin/bash
# Verify step 3: Pruner is configured and CronJob exists
kubectl get tektonconfig config -o jsonpath='{.spec.pruner.keep}' 2>/dev/null | grep -q . && \
kubectl get cronjob -A --no-headers 2>/dev/null | grep -qi prun
