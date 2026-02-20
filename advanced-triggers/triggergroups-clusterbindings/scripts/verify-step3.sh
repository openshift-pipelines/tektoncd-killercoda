#!/bin/bash
# Verify step 3: EventListeners exist in multiple namespaces
kubectl get eventlistener team-listener -n team-frontend &>/dev/null && \
kubectl get eventlistener team-listener -n team-backend &>/dev/null
