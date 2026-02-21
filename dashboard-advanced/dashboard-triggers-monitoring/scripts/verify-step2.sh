#!/bin/bash
kubectl get taskrun -o name 2>/dev/null | grep -q taskrun
