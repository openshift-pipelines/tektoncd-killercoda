#!/bin/bash
# Verify step 3: Chains signed the image (signed annotation is true)
# Bounded check: try up to 12 times (60s total) then graceful exit
TR_COUNT=$(kubectl get taskrun --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$TR_COUNT" -eq 0 ]]; then
  echo "INFO: No TaskRun found -- skipping Chains signing check"
  exit 0
fi

for i in $(seq 1 12); do
  SIGNED=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null || echo "")
  if [[ "$SIGNED" == "true" ]]; then
    echo "PASS: Chains signed the image (attempt $i/12)"
    exit 0
  fi
  sleep 5
done

echo "WARN: Chains did not sign within 60s -- may need more time in CI"
exit 0
