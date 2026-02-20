# Use a Bundle in a PipelineRun

Now that we have a Task stored as a bundle in the registry, let's use it in
a PipelineRun. Instead of installing the Task on the cluster with
`kubectl apply`, we reference it directly from the registry using the
**Bundle resolver**.

## Create a Pipeline that uses the Bundle resolver

Create a Pipeline that references the bundled Task:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: bundle-demo-pipeline
spec:
  tasks:
    - name: run-bundled-task
      taskRef:
        resolver: bundles
        params:
          - name: bundle
            value: "localhost:5000/my-task-bundle:v1"
          - name: name
            value: "my-task"
          - name: kind
            value: task
EOF
```

Notice the key differences from a normal `taskRef`:
- **resolver: bundles** -- tells Tekton to fetch the Task from an OCI bundle
- **bundle** -- the full registry URL and tag of the bundle
- **name** -- the name of the Task inside the bundle
- **kind** -- the type of resource to resolve (task or pipeline)

## Run the Pipeline

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: bundle-demo-run-
spec:
  pipelineRef:
    name: bundle-demo-pipeline
EOF
```

Wait for it to complete:

```bash
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=bundle-demo-pipeline --timeout=120s
```

## Check the logs

```bash
tkn pipelinerun logs --last -f
```

You should see the output from the bundled Task:

```
[run-bundled-task : print-message] Hello from a Tekton Bundle!
[run-bundled-task : print-message] This Task was loaded from an OCI bundle!
```

## Run with a custom parameter

You can also pass parameters to the bundled Task. Create a Pipeline that
exposes the Task parameter:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: bundle-param-pipeline
spec:
  params:
    - name: greeting
      type: string
      default: "Greetings from a parameterized bundle!"
  tasks:
    - name: run-bundled-task
      taskRef:
        resolver: bundles
        params:
          - name: bundle
            value: "localhost:5000/my-task-bundle:v1"
          - name: name
            value: "my-task"
          - name: kind
            value: task
      params:
        - name: message
          value: "$(params.greeting)"
EOF
```

Run it with a custom message:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: bundle-param-run-
spec:
  pipelineRef:
    name: bundle-param-pipeline
  params:
    - name: greeting
      value: "Bundles are the future of Task distribution!"
EOF
```

```bash
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=bundle-param-pipeline --timeout=120s
```

```bash
tkn pipelinerun logs --last -f
```

The Task was never installed on the cluster -- it was fetched from the
registry at runtime. This is the power of Tekton Bundles.
