# Create Tasks using kubectl

Before we can use the Dashboard to run Pipelines, we need to create some Tasks
and a Pipeline. Let's create the same `hello` and `goodbye` Tasks from the
basic-pipeline tutorial.

## Create the hello Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
spec:
  steps:
    - name: hello
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "Hello World!"
EOF
```

## Create the goodbye Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: goodbye
spec:
  steps:
    - name: goodbye
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "Goodbye World!"
EOF
```

## Verify in the Dashboard

Go back to the Tekton Dashboard in your browser and click on **Tasks** in the
left sidebar. You should now see the `hello` and `goodbye` Tasks listed.

You can also verify from the terminal:

```bash
tkn task list
```
