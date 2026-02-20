# Verify automated cleanup

Let's verify that the retention policy is working by examining the Results
behavior.

## Check current record count

```bash
echo "=== Current Records ==="
kubectl get taskrun -o name | wc -l | tr -d ' '
echo " TaskRuns in Kubernetes"
echo ""

# Query Results API if accessible
RESULTS_SVC=$(kubectl get svc -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results -o name 2>/dev/null | head -1)
if [ -n "$RESULTS_SVC" ]; then
  kubectl port-forward -n tekton-pipelines $RESULTS_SVC 8091:8080 &>/dev/null &
  PF_PID=$!
  sleep 2
  curl -sk https://localhost:8091/apis/results.tekton.dev/v1alpha2/parents/default/results 2>/dev/null | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Results API records: {len(d.get(\"results\",[]))}')" 2>/dev/null || \
    echo "Results API query completed"
  kill $PF_PID 2>/dev/null
fi
```

## Generate more records and observe

Create additional TaskRuns to trigger retention:

```bash
for i in $(seq 1 5); do
  cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: retention-batch2-
spec:
  taskRef:
    name: retention-demo
EOF
done

echo "Created 5 more TaskRuns (total should be ~10)"
sleep 15
```

## Check the retention worker

The Results retention worker runs periodically to clean up expired records:

```bash
echo "=== Results Pods ==="
kubectl get pods -l app.kubernetes.io/part-of=tekton-results -n tekton-pipelines

echo ""
echo "=== Results Logs (retention-related) ==="
kubectl logs -l app.kubernetes.io/part-of=tekton-results -n tekton-pipelines \
  --tail=30 2>/dev/null | grep -i "retention\|cleanup\|delete\|prune" || \
  echo "No retention log entries yet (worker may not have run)"
```

## Understand the cleanup lifecycle

```bash
echo "=== Retention Lifecycle ==="
echo ""
echo "1. TaskRun/PipelineRun completes"
echo "2. Results watcher stores the record in the database"
echo "3. Retention worker runs periodically (every few minutes)"
echo "4. Worker checks each record against retention policy:"
echo "   - Is it older than retention-period? -> DELETE"
echo "   - Are there more than retention-limit records? -> DELETE oldest"
echo "5. Deleted from database; Kubernetes resources unaffected"
echo ""
echo "Note: Retention only affects the Results database."
echo "Kubernetes PipelineRun/TaskRun objects are managed separately"
echo "(use Tekton Pruner or automatic-pruning for those)."
```

## Final record count

```bash
echo "=== Final State ==="
echo "TaskRuns in Kubernetes: $(kubectl get taskrun -o name | wc -l | tr -d ' ')"
echo ""
echo "The retention policy will clean up old Results records"
echo "in the background. In a long-running cluster, you would"
echo "see the database size stabilize over time."
```

## Verify

Confirm the retention setup is complete:

```bash
kubectl get configmap tekton-results-retention -n tekton-pipelines &>/dev/null
```
