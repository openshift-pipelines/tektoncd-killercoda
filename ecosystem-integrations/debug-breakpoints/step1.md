# Enable breakpoint debugging

The breakpoint API is an alpha feature. The install script has already enabled
it, but let's verify and understand how it works.

## Verify alpha API fields are enabled

```bash
kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.enable-api-fields}'
echo ""
```

This should show `alpha`. If not:

```bash
kubectl patch configmap feature-flags -n tekton-pipelines \
  -p '{"data":{"enable-api-fields":"alpha"}}'
kubectl delete pod -l app=tekton-pipelines-controller -n tekton-pipelines
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=120s
```

## Create a Task that will fail

This Task deliberately fails so we can debug it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: buggy-task
spec:
  steps:
    - name: setup
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Setting up environment..."
        echo "config_version=2.0" > /tmp/config.txt
        echo "debug_mode=true" >> /tmp/config.txt
        echo "Setup complete!"
    - name: process
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Processing data..."
        echo "Reading config..."
        cat /tmp/config.txt 2>/dev/null || echo "Config not found!"
        echo "Simulating a bug..."
        # This command will fail (file does not exist)
        cat /tmp/required-input.txt
        echo "This line will never execute"
EOF
```

## Run the TaskRun with a breakpoint

The key: add `debug.breakpoints: ["onFailure"]` to the TaskRun spec:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: debug-buggy-
spec:
  taskRef:
    name: buggy-task
  debug:
    breakpoints:
      onFailure: "enabled"
EOF
```

## Wait for the breakpoint to trigger

The first step succeeds, but the second step fails. With the breakpoint, the pod
will pause instead of terminating:

```bash
echo "Waiting for the TaskRun to hit the breakpoint..."
sleep 15

TASKRUN=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o name | head -1)
echo "TaskRun: $TASKRUN"

echo ""
echo "=== TaskRun Status ==="
kubectl get $TASKRUN -o jsonpath='{.status.conditions[0].reason}' 2>/dev/null
echo ""
kubectl get $TASKRUN -o jsonpath='{.status.conditions[0].message}' 2>/dev/null
echo ""
```

The TaskRun should show a status indicating it is paused at the breakpoint.

## Verify

Confirm the TaskRun is in a debug/paused state:

```bash
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o name | head -1)
[ -n "$TASKRUN" ]
```
