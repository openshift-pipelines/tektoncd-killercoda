#!/bin/bash
kubectl get task checkout &>/dev/null && kubectl get task maven-build &>/dev/null
