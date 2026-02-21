# Understand Dashboard extensions

Dashboard extensions allow you to add custom resource views to the sidebar.

## Verify Dashboard is running

```bash
kubectl get pods -l app.kubernetes.io/part-of=tekton-dashboard -n tekton-pipelines
```

## Access the Dashboard

<!-- e2e-skip -->
```bash
kubectl port-forward svc/tekton-dashboard -n tekton-pipelines 9097:9097 &>/dev/null &
echo "Dashboard available at: http://localhost:9097"
echo "On Killercoda, use the Traffic/Ports tab to access port 9097"
```

## How extensions work

```bash
echo "=== Dashboard Extension Mechanism ==="
echo ""
echo "Extensions are Kubernetes resources that tell the Dashboard"
echo "to display additional resource types in the sidebar."
echo ""
echo "When you create an extension, the Dashboard adds:"
echo "  1. A new entry in the sidebar navigation"
echo "  2. A list view showing all instances of that resource"
echo "  3. A detail view for individual resources"
echo ""
echo "Supported extension types:"
echo "  - Kubernetes core resources (ConfigMaps, Secrets, Deployments)"
echo "  - Custom Resource Definitions (CRDs)"
echo "  - Any namespaced Kubernetes resource"
```

## Verify

Confirm Dashboard is running:

```bash
kubectl get svc tekton-dashboard -n tekton-pipelines &>/dev/null
```
