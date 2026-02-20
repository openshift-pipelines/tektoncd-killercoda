#!/bin/bash
# Verify step 1: EventListener github-listener exists and is ready
kubectl get eventlistener github-listener &>/dev/null && \
kubectl get pods -l eventlistener=github-listener --no-headers 2>/dev/null | grep -q "Running"
