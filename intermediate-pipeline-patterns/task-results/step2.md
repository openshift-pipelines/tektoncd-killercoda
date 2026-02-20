# Pass Results between Tasks in a Pipeline

The real power of Results comes when you pass them between Tasks in a Pipeline.
A downstream Task can reference an upstream Task's Result using the syntax
`$(tasks.<task-name>.results.<result-name>)`.

## Create a Task that consumes a Result

First, create a `use-id` Task that accepts a build ID as a parameter and uses
it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: use-id
spec:
  params:
    - name: build-id
      type: string
      description: The build ID to use
  steps:
    - name: display
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Using build ID: \$(params.build-id)"
        echo "Tagging artifacts with: \$(params.build-id)"
EOF
```

## Create a Pipeline that passes Results

Now create a Pipeline that runs `generate-id` first, then passes its Result to
`use-id`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: results-demo
spec:
  tasks:
    - name: generate-id
      taskRef:
        name: generate-id
    - name: use-id
      runAfter:
        - generate-id
      taskRef:
        name: use-id
      params:
        - name: build-id
          value: "\$(tasks.generate-id.results.build-id)"
EOF
```

The key line is `value: "$(tasks.generate-id.results.build-id)"` -- this tells
Tekton to take the `build-id` Result from the `generate-id` Task and pass it as
the `build-id` parameter to the `use-id` Task.

## Run the Pipeline

```bash
tkn pipeline start results-demo --showlog
```

Watch the output: the `generate-id` Task runs first and emits a build ID. Then
the `use-id` Task runs with that same build ID passed as a parameter. The two
Tasks are now communicating through Results.

## Verify

Check that the Pipeline was created successfully:

```bash
kubectl get pipeline results-demo
```
