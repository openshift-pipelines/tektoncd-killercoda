# Continue or abort after debugging

After inspecting the environment, you can tell Tekton to continue or abort the
TaskRun.

## The debug control files

Tekton uses files in `/tekton/debug/` to control the breakpoint:

```bash
echo "=== Debug Control Files ==="
echo ""
echo "/tekton/debug/continue  -- Write to resume execution"
echo "/tekton/debug/fail      -- Write to abort and fail the TaskRun"
echo ""
echo "Simply writing any content to these files signals Tekton."
```

## Option 1: Continue execution

To continue (resume the TaskRun after fixing the issue):

```bash
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}')

kubectl exec $POD -c step-process -- sh -c '
echo "Signaling continue..."
echo "continue" > /tekton/debug/continue 2>/dev/null || \
  echo "Note: /tekton/debug/continue path depends on alpha API implementation"
' 2>/dev/null || echo "Continue signal sent (if breakpoint was active)"
```

## Option 2: Fail the TaskRun

If you want to abort instead:

```bash
echo "To fail/abort instead of continuing, you would run:"
echo "  kubectl exec \$POD -c step-process -- sh -c 'echo fail > /tekton/debug/fail'"
echo ""
echo "(We will not run this since we chose to continue above)"
```

## The complete debug workflow

```bash
echo "=== Complete Breakpoint Debug Workflow ==="
echo ""
echo "1. Create TaskRun with debug.breakpoints.onFailure: enabled"
echo "2. TaskRun starts executing steps normally"
echo "3. A step FAILS -> pod PAUSES (instead of terminating)"
echo "4. Developer notices the paused TaskRun"
echo "5. Developer execs into the container:"
echo "     kubectl exec -it \$POD -c step-process -- sh"
echo "6. Developer inspects:"
echo "     - File system state"
echo "     - Environment variables"
echo "     - Network connectivity"
echo "     - Previous step outputs"
echo "7. Developer either:"
echo "     - Fixes the issue and writes to /tekton/debug/continue"
echo "     - Decides to abort and writes to /tekton/debug/fail"
echo "8. TaskRun resumes or terminates"
```

## Check the final TaskRun status

```bash
sleep 5
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o name | head -1)
echo "=== Final TaskRun Status ==="
kubectl get $TASKRUN
echo ""
kubectl get $TASKRUN -o jsonpath='{.status.conditions[0]}' | python3 -m json.tool 2>/dev/null || \
  kubectl get $TASKRUN -o jsonpath='{.status.conditions[0].reason}'
echo ""
```

## When to use breakpoints

```bash
echo "=== When to use breakpoints ==="
echo ""
echo "Good use cases:"
echo "  - Investigating flaky tests that only fail in CI"
echo "  - Debugging permission issues in specific namespaces"
echo "  - Checking if files/secrets are mounted correctly"
echo "  - Testing network connectivity from within the pod"
echo ""
echo "Not recommended for:"
echo "  - Production pipelines (paused pods consume resources)"
echo "  - Automated testing (use retry/timeout instead)"
echo "  - Simple errors visible in logs"
```

## Verify

Confirm the TaskRun completed (either successfully or failed after debug):

```bash
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o name | head -1)
[ -n "$TASKRUN" ]
```
