# Run Pipelines and see Results capture them

Now that Results is installed, let's create and run a Pipeline, then verify
that the Results watcher captured the execution data.

## Create a simple Pipeline

Create a Pipeline with two Tasks -- one that generates a greeting and one
that echoes a timestamp:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: greet
spec:
  steps:
    - name: greet
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Hello from Tekton Results tutorial!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: timestamp
spec:
  steps:
    - name: timestamp
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Pipeline completed at: $(date -u)"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: greeting-pipeline
spec:
  tasks:
    - name: say-hello
      taskRef:
        name: greet
    - name: print-time
      taskRef:
        name: timestamp
      runAfter:
        - say-hello
EOF
```

## Run the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: greeting-pipeline-run-
spec:
  pipelineRef:
    name: greeting-pipeline
EOF
```

Wait for the PipelineRun to complete:

```bash
tkn pipelinerun list
```

```bash
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=greeting-pipeline --timeout=120s
```

Check the logs to confirm it ran successfully:

```bash
tkn pipelinerun logs --last -f
```

## Verify Results captured it

The Results watcher continuously monitors for completed runs. Give it a
moment to process, then check for Result resources:

```bash
sleep 5
kubectl get results.results.tekton.dev -n default
```

You should see at least one Result entry. The Results watcher automatically
created a Result record that links to the PipelineRun and its child
TaskRuns. This data will persist even if the original PipelineRun is
later deleted from the cluster.
