# Reference a Pipeline from a PipelineTask

Now create a **parent Pipeline** that uses `pipelineRef` instead of `taskRef`
in a PipelineTask. This tells Tekton to create a child PipelineRun for that
task.

## Create a deploy Task

This Task simulates a deployment step that runs after the child Pipeline:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy
spec:
  params:
    - name: component
      type: string
  steps:
    - name: deploy
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Deploying component: \$(params.component)"
        echo "Deployment complete!"
EOF
```

## Create the parent Pipeline with pipelineRef

The key difference: this PipelineTask uses **`pipelineRef`** to reference the
`build-pipeline` instead of a Task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: release-pipeline
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
    - name: deploy
      runAfter:
        - build-and-test
      taskRef:
        name: deploy
      params:
        - name: component
          value: "\$(params.component)"
EOF
```

## Run the parent Pipeline

```bash
tkn pipeline start release-pipeline \
  -p component="api-server" \
  --showlog
```

Watch the output carefully. Tekton:

1. Creates the parent PipelineRun
2. For the `build-and-test` task, creates a **child PipelineRun** of `build-pipeline`
3. The child PipelineRun runs compile and test tasks
4. After the child completes, the parent continues with the deploy task

## Inspect the child PipelineRun

List all PipelineRuns to see both parent and child:

```bash
kubectl get pipelinerun
```

You should see two PipelineRuns: one for `release-pipeline` (parent) and one for
`build-pipeline` (child, created automatically).

## Verify

Confirm the parent Pipeline exists and a child PipelineRun was created:

```bash
kubectl get pipeline release-pipeline
kubectl get pipelinerun -l tekton.dev/pipeline=build-pipeline
```
