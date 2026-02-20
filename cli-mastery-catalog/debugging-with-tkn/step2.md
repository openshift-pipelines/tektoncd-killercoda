# Deep dive into failure analysis

Now that we have a failed PipelineRun, let's use the `tkn` CLI and `kubectl` to
systematically debug each failure.

## Step 1: List all TaskRuns from the PipelineRun

First, list the TaskRuns that belong to our failed PipelineRun:

```bash
tkn taskrun list -l tekton.dev/pipeline=buggy-pipeline
```

This shows each TaskRun's name, status, and duration. Identify the failed ones.

## Step 2: Debug the script error (build Task)

Get detailed information about the `build` TaskRun:

```bash
BUILD_TR=$(tkn taskrun list -l tekton.dev/pipelineTask=build --sort-by=creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "Build TaskRun: $BUILD_TR"
tkn taskrun describe "$BUILD_TR"
```

The describe output shows:
- The **Status** and **Reason** (e.g., `Failed`)
- The **Message** with details about what went wrong
- The **Steps** section showing which Step failed

Now get the logs for the failed TaskRun:

```bash
tkn taskrun logs "$BUILD_TR"
```

The logs clearly show the script error: `ERROR: undefined variable 'foo'`
followed by a non-zero exit. This is a straightforward script bug.

## Step 3: Debug the image pull error (deploy Task)

Get information about the `deploy` TaskRun:

```bash
DEPLOY_TR=$(tkn taskrun list -l tekton.dev/pipelineTask=deploy --sort-by=creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "Deploy TaskRun: $DEPLOY_TR"
tkn taskrun describe "$DEPLOY_TR"
```

For image pull failures, the `tkn taskrun logs` command may not show much
because the container never started. This is where `kubectl` becomes essential.

## Step 4: Use kubectl for low-level debugging

Find the pod for the deploy TaskRun:

```bash
DEPLOY_POD=$(kubectl get pod -l tekton.dev/taskRun="$DEPLOY_TR" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
echo "Deploy pod: $DEPLOY_POD"
```

If the pod exists, describe it to see Kubernetes-level events:

```bash
kubectl describe pod "$DEPLOY_POD" 2>/dev/null || echo "Pod may have been cleaned up -- check TaskRun status instead"
```

In the **Events** section of the pod description, you will see messages like:
- `Failed to pull image "noexist/this-image-does-not-exist:v999"`
- `Error: ImagePullBackOff`

This tells you the exact image that failed and why.

## Step 5: Check the PipelineRun conditions

For a programmatic view of the failure, inspect the PipelineRun conditions:

```bash
kubectl get pipelinerun -l tekton.dev/pipeline=buggy-pipeline \
  --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.conditions[0]}' | python3 -m json.tool
```

This JSON shows:
- `status: "False"` - the PipelineRun failed
- `reason` - why it failed
- `message` - a human-readable description

## The debugging flow

You now know the systematic debugging flow:

```
tkn pipelinerun describe  (high-level overview)
    |
    v
tkn taskrun list          (find the failed TaskRuns)
    |
    v
tkn taskrun describe      (get failure details)
    |
    v
tkn taskrun logs          (read the script output)
    |
    v
kubectl describe pod      (low-level Kubernetes events)
```
