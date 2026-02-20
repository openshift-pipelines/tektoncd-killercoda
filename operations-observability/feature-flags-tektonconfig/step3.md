# Configure operational settings

Beyond feature gates, Tekton has operational settings that affect performance,
security, and resource usage.

## Configure results format and size

Switch to sidecar-based results for larger result sizes:

```bash
kubectl patch configmap feature-flags -n tekton-pipelines \
  -p '{"data":{
    "results-from": "sidecar-logs",
    "max-result-size": "10240"
  }}'
```

This changes results from the default 4KB termination message to sidecar-based
collection, supporting up to 10KB per result.

## Configure default timeouts

Set default timeouts for TaskRuns and PipelineRuns:

```bash
kubectl get configmap config-defaults -n tekton-pipelines -o yaml

kubectl patch configmap config-defaults -n tekton-pipelines \
  -p '{"data":{
    "default-timeout-minutes": "60",
    "default-managed-by-label-value": "tekton-pipelines"
  }}'
```

## View the reconciled configuration

If using the Operator, check how TektonConfig reconciles to ConfigMaps:

```bash
echo "=== Pipeline Configuration ==="
echo ""
echo "Feature Flags:"
kubectl get configmap feature-flags -n tekton-pipelines -o json | \
  python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', {})
for k, v in sorted(data.items()):
    print(f'  {k}: {v}')
" 2>/dev/null

echo ""
echo "Defaults:"
kubectl get configmap config-defaults -n tekton-pipelines -o json | \
  python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', {})
for k, v in sorted(data.items()):
    print(f'  {k}: {v}')
" 2>/dev/null
```

## Restart controller to apply all changes

```bash
kubectl delete pod -l app=tekton-pipelines-controller -n tekton-pipelines
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=120s
echo "All configuration changes applied!"
```

## Test the updated config

Create a Task with a larger result to verify the sidecar results mode:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: large-result-task
spec:
  results:
    - name: report
      type: string
  steps:
    - name: generate
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        # Generate a result larger than 4KB (the old limit)
        python3 -c "print('x' * 5000)" > \$(results.report.path) 2>/dev/null || \
          head -c 5000 /dev/urandom | base64 | head -c 5000 > \$(results.report.path)
        echo "Generated large result (5KB)"
EOF

cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: large-result-
spec:
  taskRef:
    name: large-result-task
EOF
```

```bash
sleep 10
echo "=== TaskRun status ==="
tkn taskrun list
```

## Verify

Confirm the operational settings are applied:

```bash
RESULTS_FROM=$(kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.results-from}' 2>/dev/null)
echo "results-from: $RESULTS_FROM"
[ "$RESULTS_FROM" = "sidecar-logs" ]
```
