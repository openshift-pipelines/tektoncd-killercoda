#!/bin/bash
# Verify step 2: EventListener with multiple triggers exists
kubectl get eventlistener multi-trigger-listener &>/dev/null
