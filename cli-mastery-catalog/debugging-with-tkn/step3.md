# Fix and rerun with tkn

Now that we have identified the bugs, let's fix them and demonstrate the
debug-fix-rerun cycle.

## Fix the script error Task

The `script-error-task` had a simulated compilation error. Let's fix it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: script-error-task
spec:
  steps:
    - name: compile
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Compiling source code..."
        echo "Compilation successful!"
        exit 0
EOF
```

## Fix the bad image Task

The `bad-image-task` referenced a nonexistent image. Let's fix it to use a
valid image:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: bad-image-task
spec:
  steps:
    - name: run
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Deploying application..."
        echo "Deployment complete!"
EOF
```

## Rerun the Pipeline with --last

The `tkn pipeline start --last` command reruns a Pipeline with the same
parameters and configuration as the most recent run:

```bash
tkn pipeline start buggy-pipeline --last --showlog
```

This time, all three Tasks should succeed:
- `lint` - passes as before
- `build` - now compiles successfully
- `deploy` - now uses a valid image and deploys

## Verify the fix

Confirm the PipelineRun succeeded:

```bash
tkn pipelinerun describe --last
```

All Tasks should show **Succeeded** status.

## Demonstrate cancellation

Sometimes you realize a PipelineRun is wrong while it is still running and want
to stop it immediately. Let's demonstrate `tkn pipelinerun cancel`.

First, create a slow Pipeline to give us time to cancel it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: very-slow-task
spec:
  steps:
    - name: wait
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Starting very slow task..."
        sleep 300
        echo "Done!"
EOF
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: slow-pipeline
spec:
  tasks:
    - name: slow-step
      taskRef:
        name: very-slow-task
EOF
```

Start it without `--showlog` so the command returns immediately:

```bash
tkn pipeline start slow-pipeline
```

Wait a few seconds for it to start running:

```bash
sleep 5
tkn pipelinerun list
```

Now cancel the running PipelineRun:

```bash
LATEST_PR=$(tkn pipelinerun list -l tekton.dev/pipeline=slow-pipeline -o jsonpath='{.items[0].metadata.name}')
tkn pipelinerun cancel "$LATEST_PR"
```

Verify the cancellation:

```bash
tkn pipelinerun describe "$LATEST_PR"
```

The status should show as **Cancelled** (or **PipelineRunCancelled**).

## The debug-fix-rerun cycle

You have now practiced the complete debugging workflow:

1. **Run** - start a Pipeline
2. **Diagnose** - use `tkn pipelinerun describe`, `tkn taskrun logs`, and
   `kubectl describe pod` to find the issue
3. **Fix** - update the Task or Pipeline definition
4. **Rerun** - use `tkn pipeline start --last` to quickly rerun
5. **Verify** - confirm the fix worked
6. **Cancel** - stop a running Pipeline if needed
