# Configure log retention and access

## The pruning and retention story

In production Kubernetes clusters, you must prune old PipelineRuns and
TaskRuns to prevent etcd from growing too large. But pruning deletes the
Kubernetes resources - and with them, the logs.

With Results as the Dashboard's external logs backend, you get the best of
both worlds:

- **Prune aggressively** - keep only a few hours or days of PipelineRuns in
  Kubernetes to keep etcd healthy
- **Keep full history** - Results stores everything in PostgreSQL, available
  through the Dashboard for weeks, months, or longer

## Simulate pruning

Let's run another PipelineRun, then delete it entirely (simulating what a
pruner would do):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: ci-pipeline-run-2
spec:
  pipelineRef:
    name: ci-pipeline
EOF
```

```bash
kubectl wait --for=condition=Succeeded pipelinerun/ci-pipeline-run-2 --timeout=120s
```

Wait for Results to capture it:

```bash
sleep 15
```

Now delete the entire PipelineRun - not just the pods, but the Kubernetes
resource itself:

```bash
kubectl delete pipelinerun ci-pipeline-run-2
```

Verify the PipelineRun is gone from Kubernetes:

```bash
kubectl get pipelinerun ci-pipeline-run-2 2>&1 || true
```

You should see "not found". But check Results:

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Results still stored: {len(results)}')
print('The pruned PipelineRun data is preserved in Results!')
"
```

The data persists in Results even after the Kubernetes resource is deleted.
The Dashboard can still display this run from its Results backend.

## View the Results retention configuration

Results has its own retention settings. Check the current configuration:

```bash
kubectl get configmap tekton-results-config -n tekton-pipelines -o yaml | grep -A5 -E "completed_run_grace_period|retention"
```

## Run a batch of Pipelines to demonstrate scale

```bash
for i in 3 4 5; do
  cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: ci-pipeline-run-${i}
spec:
  pipelineRef:
    name: ci-pipeline
EOF
  sleep 2
done
```

Wait for all to complete:

```bash
sleep 45
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=ci-pipeline --timeout=120s
```

Give Results time to capture:

```bash
sleep 15
```

Now simulate aggressive pruning - delete all PipelineRuns:

```bash
kubectl delete pipelinerun -l tekton.dev/pipeline=ci-pipeline
```

Verify Kubernetes has no PipelineRuns left:

```bash
kubectl get pipelinerun -l tekton.dev/pipeline=ci-pipeline 2>&1
```

But Results has the complete history:

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Total results preserved after pruning: {len(results)}')
print()
print('=== Pipeline run history (available in Dashboard) ===')
for r in results:
    created = r.get('createTime', 'unknown')
    print(f'  {r[\"name\"]} (created: {created})')
print()
print('All of these runs are viewable in the Dashboard via Results!')
"
```

## The "aha moment"

This is the key insight:

1. **Without Results**: Pruning = permanent data loss. The Dashboard shows
   nothing for deleted runs.
2. **With Results as external logs**: Pruning only cleans up Kubernetes
   resources. The Dashboard seamlessly displays all historical runs from
   Results, including their full logs.

You can prune PipelineRuns after 1 hour for etcd health while keeping months
of pipeline history in the Dashboard. Operations teams and developers both
get what they need.
