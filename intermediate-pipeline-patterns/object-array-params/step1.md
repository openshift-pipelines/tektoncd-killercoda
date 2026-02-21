# Use object-type parameters

Object parameters let you group related values into a single structured
parameter. Instead of passing `image`, `tag`, and `registry` as three separate
string parameters, you can pass one `config` object with all three fields.

## Create a Task with an object parameter

This Task accepts a `config` parameter of type `object` with three properties:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-with-config
spec:
  params:
    - name: config
      type: object
      properties:
        image:
          type: string
        tag:
          type: string
        registry:
          type: string
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Build Configuration"
        echo "========================================="
        echo "Registry: \$(params.config.registry)"
        echo "Image:    \$(params.config.image)"
        echo "Tag:      \$(params.config.tag)"
        echo ""
        echo "Full image ref: \$(params.config.registry)/\$(params.config.image):\$(params.config.tag)"
        echo "Build complete!"
EOF
```

Notice how the parameter declaration includes `properties` with typed fields, and
you access individual fields using dot notation: `$(params.config.registry)`.

## Run the Task with object values

Provide the object parameter values in a TaskRun:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: build-with-config-
spec:
  taskRef:
    name: build-with-config
  params:
    - name: config
      value:
        image: "my-app"
        tag: "v1.2.3"
        registry: "registry.example.com"
EOF
```

Wait for the TaskRun to complete and check the logs:

<!-- e2e-skip -->
```bash
sleep 5
tkn taskrun list
tkn taskrun logs --last
```

You should see the build configuration printed with all three object fields
resolved to their provided values.

## Verify

Confirm the Task with object parameter exists:

<!-- e2e-skip -->
```bash
kubectl get task build-with-config
```
