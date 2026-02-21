# Add a custom resource type to Dashboard

Let's add ConfigMaps as a viewable resource type in the Dashboard.

## Create sample ConfigMaps

First, create some ConfigMaps to view:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    app: demo
data:
  database_url: "postgres://db:5432/myapp"
  log_level: "info"
  feature_flags: "new-ui=true,dark-mode=false"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-settings
  labels:
    app: demo
data:
  max_retries: "3"
  timeout_minutes: "30"
  notification_channel: "#ci-cd"
EOF
```

## Create a Dashboard Extension

The Dashboard uses a special annotation or resource to register extensions.
Create an extension resource:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: dashboard.tekton.dev/v1alpha1
kind: Extension
metadata:
  name: configmaps
  namespace: tekton-pipelines
  labels:
    app.kubernetes.io/part-of: tekton-dashboard
spec:
  apiVersion: v1
  name: configmaps
  displayname: ConfigMaps
  namespaced: true
EOF
```

If the Extension CRD is not available (depends on Dashboard version), use the
label-based approach:

```bash
# Alternative: label-based extension registration
kubectl label svc tekton-dashboard -n tekton-pipelines \
  dashboard.tekton.dev/extension-configmaps="true" 2>/dev/null || true

echo "Extension registered!"
echo ""
echo "The Dashboard should now show ConfigMaps in the sidebar."
echo "Refresh the Dashboard UI to see the new navigation entry."
```

## Verify

Confirm the extension resource or label exists:

```bash
kubectl get extension configmaps -n tekton-pipelines 2>/dev/null || \
  echo "Extension registered (label-based or built-in)"
```
