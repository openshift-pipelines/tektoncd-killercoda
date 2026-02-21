# Install Dashboard with Results backend

## Verify all components are running

First, confirm that Tekton Pipelines, Results, and the Dashboard are all
running:

```bash
echo "=== Tekton Pipelines ==="
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-pipelines

echo ""
echo "=== Tekton Results ==="
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results

echo ""
echo "=== Tekton Dashboard ==="
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-dashboard
```

All pods should be in the `Running` state.

## Understand the external logs feature

By default, the Dashboard reads logs directly from Kubernetes pod logs. When
you configure the `--external-logs` flag, the Dashboard uses the Results API
as a fallback source for logs. The flow is:

1. Dashboard tries to get logs from the pod (fast, real-time)
2. If the pod no longer exists, Dashboard queries the Results API
3. Results returns the stored logs from its database

This means logs are available regardless of pod lifecycle.

## Configure the Dashboard for external logs

The Dashboard needs to be reconfigured with the `--external-logs` flag
pointing to the Results API endpoint. We will patch the Dashboard deployment
to add this argument:

```bash
RESULTS_API="https://tekton-results-api-service.tekton-pipelines.svc.cluster.local:8080"

kubectl patch deployment tekton-dashboard \
  -n tekton-pipelines \
  --type=json \
  -p="[{
    \"op\": \"add\",
    \"path\": \"/spec/template/spec/containers/0/args/-\",
    \"value\": \"--external-logs=${RESULTS_API}\"
  }]"
```

Wait for the Dashboard to restart with the new configuration:

```bash
kubectl rollout status deployment/tekton-dashboard -n tekton-pipelines --timeout=60s
```

## Verify the configuration

Confirm the Dashboard now has the `--external-logs` flag:

```bash
kubectl get deployment tekton-dashboard -n tekton-pipelines \
  -o jsonpath='{.spec.template.spec.containers[0].args}' | python3 -m json.tool
```

You should see `--external-logs=https://tekton-results-api-service...` in the
arguments list.

## Start the Dashboard port-forward

Start a port-forward so you can access the Dashboard:

<!-- e2e-skip -->
```bash
kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097 &
sleep 2
echo "Dashboard is available at http://localhost:9097"
```

The Dashboard is now configured to use Results as its external logs backend.
In the next step, we will run Pipelines and see this in action.
