# Create and use a StepAction

A **StepAction** defines a reusable step that can be referenced from any Task.
It uses `apiVersion: tekton.dev/v1beta1` and `kind: StepAction`. Inside a Task,
you reference a StepAction by using `ref` instead of inlining the step's
`image` and `script` directly.

## Create a StepAction

Create a `log-message` StepAction that accepts a `message` parameter and prints
it to the console:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: StepAction
metadata:
  name: log-message
spec:
  params:
    - name: message
      type: string
      description: The message to log
  image: alpine:3.19
  script: |
    #!/usr/bin/env sh
    echo "========================================="
    echo "  LOG: \$(params.message)"
    echo "========================================="
EOF
```

There are three important things to notice here:

1. **`apiVersion: tekton.dev/v1beta1`** - StepActions use the `v1beta1` API
   version, not `v1`. This is the correct API group for StepActions.
2. **`spec.params`** declares the parameters the StepAction accepts, just like
   a Task declares params.
3. **`spec.image` and `spec.script`** define the container image and script to
   run - the same fields you would normally put inside a step in a Task.

## Create a Task that references the StepAction

Now create a Task that uses the `log-message` StepAction via `ref`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: greeting-task
spec:
  params:
    - name: greeting
      type: string
      default: "Hello from StepActions!"
  steps:
    - name: log-greeting
      ref:
        name: log-message
      params:
        - name: message
          value: "\$(params.greeting)"
EOF
```

Notice the key difference from a normal Task step:

1. **`ref: {name: log-message}`** tells Tekton to look up the `log-message`
   StepAction and use its image, script, and other configuration.
2. **`params`** are passed to the StepAction, mapping the Task's `greeting`
   parameter to the StepAction's `message` parameter.
3. The step does **not** specify `image` or `script` directly - those come
   from the referenced StepAction.

## Run the Task

<!-- e2e-skip -->
```bash
tkn task start greeting-task --showlog
```

You should see the formatted log output from the `log-message` StepAction. The
Task delegated its step execution to the StepAction definition.

## Verify the StepAction exists

<!-- e2e-skip -->
```bash
kubectl get stepaction log-message
```

This confirms that the StepAction is a standalone Kubernetes resource, separate
from the Task that uses it.
