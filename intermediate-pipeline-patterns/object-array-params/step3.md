# Object and array results in Pipelines

Tasks can emit structured results (object or array types), and Pipelines can
pass these structured values between Tasks. This enables rich data flows
without serializing everything to flat strings.

## Create a Task that emits an object result

This Task outputs build metadata as an object result:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: generate-metadata
spec:
  results:
    - name: build-info
      type: object
      properties:
        digest:
          type: string
        size:
          type: string
        timestamp:
          type: string
  steps:
    - name: produce
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        DIGEST="sha256:abc123def456"
        SIZE="42MB"
        TIMESTAMP="\$(date -u +%Y-%m-%dT%H:%M:%SZ)"

        # Write each property to the result
        echo -n "\$DIGEST" > \$(results.build-info.digest.path)
        echo -n "\$SIZE" > \$(results.build-info.size.path)
        echo -n "\$TIMESTAMP" > \$(results.build-info.timestamp.path)

        echo "Generated build metadata:"
        echo "  digest:    \$DIGEST"
        echo "  size:      \$SIZE"
        echo "  timestamp: \$TIMESTAMP"
EOF
```

## Create a Task that consumes an object parameter

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: report-metadata
spec:
  params:
    - name: info
      type: object
      properties:
        digest:
          type: string
        size:
          type: string
        timestamp:
          type: string
  steps:
    - name: report
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Build Report"
        echo "========================================="
        echo "Digest:    \$(params.info.digest)"
        echo "Size:      \$(params.info.size)"
        echo "Timestamp: \$(params.info.timestamp)"
        echo "========================================="
EOF
```

## Create a Pipeline that passes structured data

Wire the object result from the first Task into the second Task's parameter:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: structured-data-pipeline
spec:
  tasks:
    - name: build
      taskRef:
        name: generate-metadata
    - name: report
      runAfter:
        - build
      taskRef:
        name: report-metadata
      params:
        - name: info
          value:
            digest: "\$(tasks.build.results.build-info.digest)"
            size: "\$(tasks.build.results.build-info.size)"
            timestamp: "\$(tasks.build.results.build-info.timestamp)"
EOF
```

## Run the Pipeline

```bash
tkn pipeline start structured-data-pipeline --showlog
```

Watch the output -- the first Task generates build metadata as an object result,
and the second Task receives and displays it. The object fields flow naturally
between Tasks without any manual JSON parsing.

## Verify

Confirm the Pipeline succeeded:

```bash
kubectl get pipelinerun -l tekton.dev/pipeline=structured-data-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}'
echo ""
```
