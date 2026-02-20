#!/bin/bash
# Verify step 1: TektonConfig resource exists
kubectl get tektonconfig config &>/dev/null
