# Create a basic Task

With Tekton, each operation in your CI/CD workflow becomes a **Step**, which is
executed with a container image you specify. Steps are then organized in
**Tasks**, which run as a Kubernetes pod in your cluster. You can further
organize Tasks into **Pipelines**, which can control the order of execution of
several Tasks.

To create a Task, create a Kubernetes object using the Tekton API with the kind
`Task`. The following YAML file specifies a Task with one simple Step, which
prints a "Hello World!" message using the official Ubuntu image:

```yaml
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
```

Write the YAML above to a file named `task-hello.yaml`, and apply it to your
Kubernetes cluster:

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

To run this task with Tekton, you need to create a **TaskRun**, which is another
Kubernetes object used to specify run time information for a Task.

To view this TaskRun object you can run the following Tekton CLI (`tkn`)
command:

```bash
tkn task start hello --dry-run
```

After running the command above, the following TaskRun definition should be
shown:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: hello-run-
spec:
  taskRef:
    name: hello
```

To use the TaskRun above to start the `hello` Task, you can either use `tkn` or
`kubectl`.

Start with `tkn`:

```bash
tkn task start hello
```

Start with `kubectl`:

```bash
# use tkn's --dry-run option to save the TaskRun to a file
tkn task start hello --dry-run > taskRun-hello.yaml
# create the TaskRun
kubectl create -f taskRun-hello.yaml
```

Tekton will now start running your Task. To see the logs of the last TaskRun,
run the following `tkn` command:

<!-- e2e-skip -->
```bash
tkn taskrun logs --last -f
```

It may take a few moments before your Task completes. When it executes, it
should show the following output:

```
[hello] Hello World!
```
