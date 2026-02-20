# Use the Cluster Resolver for in-cluster Tasks

The **Cluster Resolver** fetches Tasks from another namespace within the same
cluster. This is the direct replacement for the removed ClusterTask resource.
Instead of defining a cluster-scoped Task, you create a regular namespace-scoped
Task in a shared namespace and reference it from other namespaces using the
Cluster Resolver.

## Create a shared namespace and Task

First, create a namespace that will hold shared Tasks for your organization:

```bash
kubectl create namespace shared-tasks
```

Now create a reusable Task in the `shared-tasks` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: shared-task
  namespace: shared-tasks
  labels:
    tutorial: remote-resolvers
spec:
  params:
    - name: message
      type: string
      default: "Hello from the shared namespace!"
  steps:
    - name: greet
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "========================================"
        echo "  Shared Task Execution"
        echo "  Message: \$(params.message)"
        echo "  Running in namespace: \$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)"
        echo "========================================"
EOF
```

Verify the Task exists in the `shared-tasks` namespace:

```bash
kubectl get task shared-task -n shared-tasks
```

## Create a TaskRun using the Cluster Resolver

Now, from the **default** namespace, create a TaskRun that references the shared
Task using the Cluster Resolver:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: cluster-resolver-demo
  labels:
    tutorial: remote-resolvers
spec:
  taskRef:
    resolver: cluster
    params:
      - name: kind
        value: task
      - name: name
        value: shared-task
      - name: namespace
        value: shared-tasks
  params:
    - name: message
      value: "This Task lives in shared-tasks but runs in default!"
EOF
```

The Cluster Resolver parameters are straightforward:

1. **`kind: task`** -- The kind of resource to resolve (task or pipeline).
2. **`name: shared-task`** -- The name of the Task in the target namespace.
3. **`namespace: shared-tasks`** -- The namespace where the Task is defined.

## Watch the TaskRun

```bash
kubectl wait --for=condition=Succeeded=False --for=condition=Succeeded=True \
  taskrun/cluster-resolver-demo --timeout=120s 2>/dev/null || true
```

```bash
tkn taskrun logs cluster-resolver-demo
```

Notice in the output that the Task definition comes from the `shared-tasks`
namespace, but the TaskRun executes in the `default` namespace.

## Verify the Task is not in the default namespace

Confirm that the `shared-task` Task does not exist in the default namespace:

```bash
kubectl get task shared-task 2>&1 || echo "As expected: shared-task is not in the default namespace"
```

## How this replaces ClusterTask

Previously, a ClusterTask was a cluster-scoped resource visible to all
namespaces. The Cluster Resolver provides the same capability with better
isolation:

- Tasks remain **namespace-scoped**, following Kubernetes best practices
- You control access via standard **RBAC** on the shared namespace
- Multiple teams can maintain **separate shared namespaces** for their own
  reusable Tasks
- There is no risk of **naming collisions** across teams, since each namespace
  has its own scope
