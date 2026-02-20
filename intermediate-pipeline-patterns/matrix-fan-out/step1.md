# Basic Matrix: run a Task across multiple parameters

In this step, you will create a Task that simulates platform testing and then use
a Matrix to fan it out across multiple platform and version combinations.

## Create the test-platform Task

This Task accepts `platform` and `version` parameters and simulates running a
test on that combination:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: test-platform
spec:
  params:
    - name: platform
      type: string
      description: The target platform
    - name: version
      type: string
      description: The target version
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Running tests"
        echo "  Platform: \$(params.platform)"
        echo "  Version:  \$(params.version)"
        echo "========================================="
        echo "Simulating test suite execution..."
        sleep 2
        echo "All tests passed for \$(params.platform)/\$(params.version)"
EOF
```

## Create a Pipeline with Matrix

Now create a Pipeline that uses a `matrix` to fan out the `test-platform` Task
across 3 platforms and 2 versions. This produces a Cartesian product of
3 x 2 = 6 TaskRuns:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: matrix-demo
spec:
  tasks:
    - name: test
      taskRef:
        name: test-platform
      matrix:
        params:
          - name: platform
            value:
              - "linux"
              - "mac"
              - "windows"
          - name: version
            value:
              - "1.20"
              - "1.21"
EOF
```

There are three important things to notice:

1. **`matrix.params`** replaces the usual `params` section on the PipelineTask.
   Each parameter gets a list of values instead of a single value.
2. Tekton computes the **Cartesian product** of all parameter lists. With 3
   platforms and 2 versions, you get 6 combinations.
3. Each combination becomes a **separate TaskRun** that runs in parallel (subject
   to cluster capacity).

## Run the Pipeline

Start the Pipeline and wait for all 6 TaskRuns to complete:

```bash
tkn pipeline start matrix-demo --showlog
```

Watch the output - you should see logs from 6 different TaskRuns, each with a
unique platform/version combination. Tekton runs them in parallel, so they may
interleave.

## Verify the Pipeline exists

Confirm the Pipeline was created:

```bash
kubectl get pipeline matrix-demo
```
