# Pass params and results between parent and child

The real power of Pipelines in Pipelines comes from passing data between parent
and child. The parent can provide parameters to the child, and the child's
Pipeline results bubble up to the parent as task results.

## Create an enhanced parent Pipeline

This version reads the child Pipeline's results and uses them in subsequent
tasks:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: notify
spec:
  params:
    - name: artifact
      type: string
    - name: test-status
      type: string
    - name: component
      type: string
  steps:
    - name: notify
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Release Notification"
        echo "========================================="
        echo "Component:   \$(params.component)"
        echo "Artifact:    \$(params.artifact)"
        echo "Test Status: \$(params.test-status)"
        echo "========================================="
        if [ "\$(params.test-status)" = "passed" ]; then
          echo "All checks passed. Ready for production!"
        else
          echo "WARNING: Tests did not pass!"
        fi
EOF
```

Now update the parent Pipeline to pass child results to the notify task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: full-release-pipeline
spec:
  params:
    - name: component
      type: string
      default: "my-service"
  tasks:
    - name: build-and-test
      pipelineRef:
        name: build-pipeline
      params:
        - name: component
          value: "\$(params.component)"
    - name: notify
      runAfter:
        - build-and-test
      taskRef:
        name: notify
      params:
        - name: artifact
          value: "\$(tasks.build-and-test.results.artifact)"
        - name: test-status
          value: "\$(tasks.build-and-test.results.test-status)"
        - name: component
          value: "\$(params.component)"
EOF
```

Notice how the child Pipeline's results (`artifact` and `test-status`) are
accessed using the standard `$(tasks.<name>.results.<result>)` syntax. The
parent treats the child Pipeline's results exactly like Task results.

## Run the full release Pipeline

```bash
tkn pipeline start full-release-pipeline \
  -p component="payment-service" \
  --showlog
```

Watch the data flow:

1. **build-and-test** (child Pipeline) compiles and tests the component
2. The child Pipeline produces `artifact` and `test-status` results
3. **notify** receives those results as parameters and generates the notification

## Verify

Confirm the full release Pipeline succeeded:

```bash
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=full-release-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
echo "Pipeline status: $STATUS"
```
