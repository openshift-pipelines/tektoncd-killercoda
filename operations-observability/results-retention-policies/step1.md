# Understand Results retention

Let's examine the default retention behavior and understand why retention
policies are needed.

## Verify Results is running

```bash
kubectl get pods -l app.kubernetes.io/part-of=tekton-results -n tekton-pipelines
```

## Generate some historical data

Create several TaskRuns to populate the Results database:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: retention-demo
spec:
  steps:
    - name: work
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "TaskRun at \$(date)"
EOF

# Create multiple TaskRuns
for i in $(seq 1 5); do
  cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: retention-demo-
spec:
  taskRef:
    name: retention-demo
EOF
done
```

Wait for them to complete:

```bash
sleep 15
echo "=== TaskRuns ==="
kubectl get taskrun
echo ""
echo "Count: $(kubectl get taskrun -o name | wc -l | tr -d ' ') TaskRuns"
```

## Check the current Results configuration

```bash
echo "=== Results Configuration ==="
kubectl get configmap tekton-results-config -n tekton-pipelines -o yaml 2>/dev/null || \
  kubectl get configmap -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results -o yaml 2>/dev/null || \
  echo "Results config not found as ConfigMap (may use env vars or defaults)"
```

## Default behavior

```bash
echo "=== Default Retention Behavior ==="
echo ""
echo "By default, Tekton Results keeps ALL records indefinitely."
echo ""
echo "Problem in production:"
echo "  - 100 PipelineRuns/day x 365 days = 36,500 records/year"
echo "  - Each record includes logs, results, and metadata"
echo "  - Database grows continuously without bounds"
echo ""
echo "Solution: Configure retention policies to automatically"
echo "clean up records based on age or count."
```

## Verify

Confirm Results is running:

```bash
kubectl get pods -l app.kubernetes.io/part-of=tekton-results -n tekton-pipelines -o name | grep -q pod
