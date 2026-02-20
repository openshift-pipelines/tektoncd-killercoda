# Configure retention policies

Tekton Results supports retention configuration through its deployment
environment variables or ConfigMap.

## Configure time-based retention

Set a retention period (in this tutorial, we use a very short period for
demonstration):

```bash
# Check if Results uses a ConfigMap or environment variables
RESULTS_DEPLOY=$(kubectl get deployment -n tekton-pipelines \
  -l app.kubernetes.io/part-of=tekton-results -o name 2>/dev/null | head -1)

echo "Results deployment: $RESULTS_DEPLOY"

# Configure retention via environment variables on the Results API deployment
kubectl set env $RESULTS_DEPLOY \
  -n tekton-pipelines \
  -c api \
  RECORD_RETENTION_PERIOD="1h" \
  RECORD_RETENTION_LIMIT="10" \
  2>/dev/null || echo "Configuring retention via alternative method..."
```

## Alternative: Configure via ConfigMap

If Results uses a ConfigMap for configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tekton-results-retention
  namespace: tekton-pipelines
data:
  retention-period: "1h"
  retention-limit: "10"
EOF

echo "Retention policy configured:"
echo "  Period: 1 hour (records older than 1h will be deleted)"
echo "  Limit: 10 (keep at most 10 records per parent)"
```

## Restart Results to apply

```bash
kubectl rollout restart deployment -l app.kubernetes.io/part-of=tekton-results \
  -n tekton-pipelines 2>/dev/null || true
sleep 10
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-results \
  -n tekton-pipelines --timeout=120s 2>/dev/null || true
echo "Results restarted with retention policies!"
```

## Understand the retention options

```bash
echo "=== Retention Configuration Options ==="
echo ""
echo "Time-based retention:"
echo "  RECORD_RETENTION_PERIOD / retention-period"
echo "  Values: 1h, 24h, 168h (7d), 720h (30d)"
echo "  Records older than this are eligible for deletion"
echo ""
echo "Count-based retention:"
echo "  RECORD_RETENTION_LIMIT / retention-limit"
echo "  Values: 10, 100, 1000"
echo "  Only keep the N most recent records per parent"
echo ""
echo "Both can be combined: delete records older than 30 days"
echo "OR if more than 1000 records exist per parent."
```

## Verify

Confirm the retention configuration exists:

```bash
kubectl get configmap tekton-results-retention -n tekton-pipelines &>/dev/null && \
  echo "Retention ConfigMap created"
```
