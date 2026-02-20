# Test access control

Now let's prove that the RBAC configuration actually works by testing what
each ServiceAccount can and cannot do.

## Create a Task in team-alpha namespace

First, create a Task in the `team-alpha` namespace using the cluster admin
context (your current user):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: team-task
  namespace: team-alpha
spec:
  steps:
    - name: greet
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Hello from team-alpha!"
EOF
```

## Test the admin ServiceAccount

The `dashboard-admin` ServiceAccount should be able to read and create Tekton
resources. Let's test using `kubectl auth can-i`:

```bash
echo "=== Admin permissions in team-alpha ==="
echo -n "Can create tasks: "
kubectl auth can-i create tasks.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-admin

echo -n "Can list taskruns: "
kubectl auth can-i list taskruns.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-admin

echo -n "Can delete pipelineruns: "
kubectl auth can-i delete pipelineruns.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-admin

echo -n "Can get pods: "
kubectl auth can-i get pods -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-admin
```

All of these should return `yes`. Now verify the admin can actually list the
Task we created:

```bash
kubectl get task team-task -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-admin
```

Create a TaskRun as the admin:

```bash
cat <<EOF | kubectl apply --as=system:serviceaccount:team-alpha:dashboard-admin -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: team-task-run-admin
  namespace: team-alpha
spec:
  taskRef:
    name: team-task
EOF
```

```bash
kubectl wait --for=condition=Succeeded taskrun/team-task-run-admin -n team-alpha --timeout=120s
```

The admin ServiceAccount successfully created and ran a TaskRun.

## Test the viewer ServiceAccount

The `dashboard-viewer` ServiceAccount should only be able to read resources.
Let's verify:

```bash
echo "=== Viewer permissions in team-alpha ==="
echo -n "Can list tasks: "
kubectl auth can-i list tasks.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-viewer

echo -n "Can get taskruns: "
kubectl auth can-i get taskruns.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-viewer

echo -n "Can create tasks: "
kubectl auth can-i create tasks.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-viewer

echo -n "Can delete pipelineruns: "
kubectl auth can-i delete pipelineruns.tekton.dev -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-viewer
```

The first two queries should return `yes` (read operations), while the last
two should return `no` (write operations).

The viewer can list the Task:

```bash
kubectl get task team-task -n team-alpha --as=system:serviceaccount:team-alpha:dashboard-viewer
```

But cannot create a TaskRun:

```bash
cat <<EOF | kubectl apply --as=system:serviceaccount:team-alpha:dashboard-viewer -f - 2>&1 || true
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: team-task-run-viewer
  namespace: team-alpha
spec:
  taskRef:
    name: team-task
EOF
```

You should see a "Forbidden" error. The viewer cannot create resources.

## Test namespace isolation

The RBAC bindings are scoped to the `team-alpha` namespace. Neither
ServiceAccount should have access to the `default` namespace:

```bash
echo "=== Namespace isolation ==="
echo -n "Admin in default namespace: "
kubectl auth can-i list tasks.tekton.dev -n default --as=system:serviceaccount:team-alpha:dashboard-admin

echo -n "Viewer in default namespace: "
kubectl auth can-i list tasks.tekton.dev -n default --as=system:serviceaccount:team-alpha:dashboard-viewer
```

Both should return `no`. The RoleBindings only grant access within
`team-alpha`, not across the entire cluster. This is how you achieve
multi-team isolation - each team's ServiceAccount can only access their own
namespace.

## Summary of access matrix

| Action | dashboard-admin | dashboard-viewer |
|--------|----------------|-----------------|
| List Tasks/Pipelines | Yes | Yes |
| View TaskRun logs | Yes | Yes |
| Create TaskRuns | Yes | **No** |
| Delete PipelineRuns | Yes | **No** |
| Access other namespaces | **No** | **No** |
