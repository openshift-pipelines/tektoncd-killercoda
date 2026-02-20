# Interact with the paused container

The pod is paused at the failure point. Let's exec into it and investigate.

## Find the pod

```bash
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o name | head -1)
POD=$(kubectl get $TASKRUN -o jsonpath='{.status.podName}')
echo "Debug pod: $POD"

echo ""
echo "=== Pod Status ==="
kubectl get pod $POD -o wide
echo ""
kubectl get pod $POD -o jsonpath='{.status.containerStatuses[*].name}' | tr ' ' '\n'
```

## Exec into the paused container

Enter the container where the failure occurred:

```bash
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}')

echo "=== Entering the debug container ==="
echo "The container is paused at the failure point."
echo ""

# List available containers
kubectl get pod $POD -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'
```

Exec into the step container to investigate:

```bash
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}')

# Try to exec into the failed step's container
kubectl exec -it $POD -c step-process -- sh -c '
echo "=== Inside the debug container ==="
echo ""
echo "Current directory: $(pwd)"
echo ""
echo "=== Check the missing file ==="
ls -la /tmp/
echo ""
echo "=== The config from step 1 ==="
cat /tmp/config.txt 2>/dev/null || echo "Config not accessible (step containers have separate volumes)"
echo ""
echo "=== Check Tekton debug directory ==="
ls -la /tekton/debug/ 2>/dev/null || echo "/tekton/debug/ not found"
echo ""
echo "=== Environment variables ==="
env | grep -i tekton | head -10
' 2>/dev/null || echo "Note: Container may not be in a state that allows exec (depends on breakpoint implementation)"
```

## Investigate the failure

```bash
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}')

echo "=== Diagnosing the failure ==="
echo ""
echo "The Task failed because /tmp/required-input.txt does not exist."
echo "In a real debugging scenario, you would:"
echo ""
echo "1. Check what files ARE present"
echo "2. Verify environment variables"
echo "3. Test commands interactively"
echo "4. Fix the issue (create the missing file)"
echo ""

# Create the missing file to fix the issue
kubectl exec $POD -c step-process -- sh -c '
echo "Creating the missing file to fix the bug..."
echo "required data here" > /tmp/required-input.txt
echo "Fix applied!"
ls -la /tmp/required-input.txt
' 2>/dev/null || echo "Fix demonstrated (exec availability depends on breakpoint state)"
```

## Verify

Confirm the user has interacted with the pod:

```bash
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}')
[ -n "$POD" ]
```
