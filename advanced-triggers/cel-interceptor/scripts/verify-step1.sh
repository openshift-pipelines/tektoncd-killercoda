#!/bin/bash
# Verify step 1: EventListener cel-demo exists and is ready
kubectl get eventlistener cel-demo &>/dev/null
