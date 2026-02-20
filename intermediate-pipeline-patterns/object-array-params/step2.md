# Use array-type parameters

Array parameters let you pass a list of values to a Task. The Task can expand
the entire array in a single command or iterate over individual elements.

## Create a Task with an array parameter

This Task accepts a `flags` parameter of type `array` and passes all values
as arguments to a command:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: run-with-flags
spec:
  params:
    - name: flags
      type: array
      description: List of flags to pass to the command
    - name: targets
      type: array
      description: List of directories to process
  steps:
    - name: lint
      image: alpine:3.19
      args:
        - "\$(params.flags[*])"
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Linting with flags"
        echo "========================================="
        echo "Received flags:"
        for flag in "\$@"; do
          echo "  - \$flag"
        done
        echo ""
        echo "Linting complete!"
    - name: process-targets
      image: alpine:3.19
      args:
        - "\$(params.targets[*])"
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Processing targets"
        echo "========================================="
        echo "Target directories:"
        for target in "\$@"; do
          echo "  Processing: \$target"
        done
        echo ""
        echo "All targets processed!"
EOF
```

Key syntax:

- **`$(params.flags[*])`** expands the entire array as separate arguments
- The `args` field receives the expanded values, available as `$@` in the script

## Run the Task with array values

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: run-with-flags-
spec:
  taskRef:
    name: run-with-flags
  params:
    - name: flags
      value:
        - "--verbose"
        - "--fix"
        - "--format=json"
    - name: targets
      value:
        - "src/"
        - "lib/"
        - "cmd/"
        - "test/"
EOF
```

Wait for the TaskRun to complete:

```bash
sleep 5
tkn taskrun logs --last
```

You should see both steps printing their respective array values: three flags and
four target directories, each expanded from the array parameter.

## Verify

Confirm the Task with array parameter exists:

```bash
kubectl get task run-with-flags
```
