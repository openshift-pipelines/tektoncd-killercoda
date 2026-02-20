# Inspect Results and use them for decisions

In a real CI/CD workflow, you often need to chain multiple Tasks that each
produce and consume Results. Let's build a 3-Task Pipeline and explore how to
inspect Result values.

## Create a data processing Pipeline

Create three Tasks: one generates data, one processes it, and one reports the
final output.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: compute-hash
spec:
  params:
    - name: input
      type: string
  results:
    - name: hash
      description: SHA256 hash of the input
  steps:
    - name: hash
      image: alpine
      script: |
        #!/usr/bin/env sh
        HASH=\$(echo -n "\$(params.input)" | sha256sum | cut -d' ' -f1)
        echo "Computed hash: \$HASH"
        echo -n "\$HASH" > \$(results.hash.path)
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: shorten-hash
spec:
  params:
    - name: full-hash
      type: string
  results:
    - name: short-hash
      description: First 8 characters of the hash
  steps:
    - name: shorten
      image: alpine
      script: |
        #!/usr/bin/env sh
        SHORT=\$(echo -n "\$(params.full-hash)" | cut -c1-8)
        echo "Shortened hash: \$SHORT"
        echo -n "\$SHORT" > \$(results.short-hash.path)
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: report
spec:
  params:
    - name: identifier
      type: string
  steps:
    - name: report
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Build Report"
        echo "  Identifier: \$(params.identifier)"
        echo "========================================="
EOF
```

Now create the Pipeline that chains all three Tasks together:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: chained-results
spec:
  params:
    - name: source-data
      type: string
      default: "my-application-v2.0"
  tasks:
    - name: compute-hash
      taskRef:
        name: compute-hash
      params:
        - name: input
          value: "\$(params.source-data)"
    - name: shorten-hash
      runAfter:
        - compute-hash
      taskRef:
        name: shorten-hash
      params:
        - name: full-hash
          value: "\$(tasks.compute-hash.results.hash)"
    - name: report
      runAfter:
        - shorten-hash
      taskRef:
        name: report
      params:
        - name: identifier
          value: "\$(tasks.shorten-hash.results.short-hash)"
EOF
```

## Run and inspect the Pipeline

```bash
tkn pipeline start chained-results --showlog
```

After the run completes, use `tkn` to inspect the PipelineRun details:

```bash
tkn pipelinerun describe --last
```

You can also extract specific Result values using `kubectl`:

```bash
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].status.childReferences}' | python3 -m json.tool
```

This shows all the TaskRun references and their status. Each TaskRun's results
are stored in its status and can be queried programmatically.
