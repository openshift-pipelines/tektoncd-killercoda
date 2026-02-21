#!/bin/bash
COUNT=$(kubectl get configmap -l app=demo -o name 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" -ge 3 ]
