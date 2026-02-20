# Matrix with include for specific combinations

The basic Matrix computes a full Cartesian product of all parameters. But
sometimes you need to add specific extra combinations that are not part of the
regular product -- for example, enabling a debug flag only for a particular
platform/version pair. The `matrix.include` field lets you do this.

## Create an enhanced Task

First, create a new Task that accepts an additional `debug` parameter:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: test-platform-v2
spec:
  params:
    - name: platform
      type: string
      description: The target platform
    - name: version
      type: string
      description: The target version
    - name: debug
      type: string
      default: "false"
      description: Enable debug mode
  steps:
    - name: test
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Running tests"
        echo "  Platform: \$(params.platform)"
        echo "  Version:  \$(params.version)"
        echo "  Debug:    \$(params.debug)"
        echo "========================================="
        if [ "\$(params.debug)" = "true" ]; then
          echo "DEBUG MODE ENABLED -- verbose output active"
          echo "Debug: loading test fixtures..."
          echo "Debug: initializing test harness..."
        fi
        echo "Simulating test suite execution..."
        sleep 2
        echo "All tests passed for \$(params.platform)/\$(params.version)"
EOF
```

## Create a Pipeline with matrix.include

Now create a Pipeline that uses `matrix.include` to add specific combinations.
The include section adds rows to the matrix that would not otherwise exist:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: matrix-include-demo
spec:
  tasks:
    - name: test
      taskRef:
        name: test-platform-v2
      matrix:
        params:
          - name: platform
            value:
              - "linux"
              - "mac"
          - name: version
            value:
              - "1.20"
              - "1.21"
        include:
          - name: linux-debug
            params:
              - name: platform
                value: "linux"
              - name: version
                value: "1.21"
              - name: debug
                value: "true"
          - name: windows-compat
            params:
              - name: platform
                value: "windows"
              - name: version
                value: "1.21"
              - name: debug
                value: "false"
EOF
```

Here is what happens with this configuration:

1. The base `matrix.params` creates a 2 x 2 = 4 Cartesian product:
   linux/1.20, linux/1.21, mac/1.20, mac/1.21. All of these get `debug: "false"`
   (the Task default).
2. The first `include` entry matches the existing linux/1.21 combination and
   adds `debug: "true"` to it. This means the linux/1.21 TaskRun will have
   debug enabled.
3. The second `include` entry adds a completely new combination (windows/1.21)
   that was not in the original Cartesian product.

The total result is 5 TaskRuns: 4 from the Cartesian product (with one modified
by include) plus 1 new combination from include.

## Run the Pipeline

```bash
tkn pipeline start matrix-include-demo --showlog
```

Watch the output carefully. You should see:
- linux/1.20, mac/1.20, mac/1.21 running with debug=false
- linux/1.21 running with debug=true (verbose output)
- windows/1.21 running with debug=false (the extra include combination)

## Verify the results

Check how many TaskRuns were created:

```bash
kubectl get taskrun -l tekton.dev/pipelineTask=test --no-headers | wc -l
```

Describe the PipelineRun to see the complete picture:

```bash
tkn pipelinerun describe --last
```

The combination of `matrix.params` and `matrix.include` gives you precise control
over your test matrix -- use the Cartesian product for broad coverage and include
for targeted additions or overrides.
