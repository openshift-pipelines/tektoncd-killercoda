# Understand read-only vs read-write Dashboard modes

## Verify the Dashboard is running

First, confirm that the Dashboard pod is running:

```bash
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-dashboard
```

The Dashboard is currently installed in **read-write mode** (using
`release-full.yaml`). This mode includes the full Dashboard with create, edit,
and delete capabilities in the UI.

## Access the read-write Dashboard

Start a port-forward to access the Dashboard:

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097 &
sleep 2
```

The Dashboard is now accessible. In read-write mode, the UI includes buttons
for creating and importing resources. Let's verify this by checking the
Dashboard deployment:

```bash
kubectl get deployment tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.template.spec.containers[0].args}' | python3 -m json.tool
```

Notice the `--read-only=false` flag (or the absence of `--read-only=true`).
This confirms read-write mode.

## Verify the existing Task is visible

```bash
kubectl get task hello-dashboard
```

The Dashboard can see this Task and, in read-write mode, could create new
Tasks and TaskRuns from the UI.

## Switch to read-only mode

Now let's see what read-only mode looks like. Stop the port-forward first:

```bash
kill %1 2>/dev/null
```

Install the read-only Dashboard (this replaces the read-write installation):

```bash
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.52.0/release.yaml
```

Wait for the Dashboard to restart:

```bash
kubectl rollout status deployment/tekton-dashboard -n tekton-pipelines --timeout=60s
```

Check the Dashboard arguments again:

```bash
kubectl get deployment tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.template.spec.containers[0].args}' | python3 -m json.tool
```

Now you should see `--read-only=true` in the arguments. In this mode, the UI
only shows viewing capabilities - no create, edit, or delete buttons appear.

## Restore read-write mode

For the rest of this tutorial, we need read-write mode so we can demonstrate
RBAC controlling access. Restore it:

```bash
kubectl apply --filename https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.52.0/release-full.yaml
kubectl rollout status deployment/tekton-dashboard -n tekton-pipelines --timeout=60s
```

## Key difference summary

| Feature | read-only (`release.yaml`) | read-write (`release-full.yaml`) |
|---------|---------------------------|----------------------------------|
| View resources | Yes | Yes |
| Create resources | No | Yes |
| Delete resources | No | Yes |
| Import YAML | No | Yes |
| Best for | Monitoring, viewers | Admins, development |

The deployment mode is a coarse-grained control. For fine-grained access,
you need Kubernetes RBAC - which we will configure in the next step.
