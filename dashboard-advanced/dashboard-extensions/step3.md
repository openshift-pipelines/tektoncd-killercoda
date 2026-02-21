# View custom resources in Dashboard

With the extension registered, custom resources appear in the Dashboard UI.

## Navigate to the custom resource view

```bash
echo "=== Viewing Custom Resources in Dashboard ==="
echo ""
echo "1. Open the Dashboard UI (port 9097)"
echo "2. Look for 'ConfigMaps' in the left sidebar"
echo "3. Click to see a list of all ConfigMaps"
echo "4. Click on 'app-config' to see its details"
echo ""
echo "The Dashboard displays:"
echo "  - Resource name and namespace"
echo "  - Labels and annotations"
echo "  - Data/spec contents"
echo "  - YAML view"
```

## Create more resources to see the list grow

```bash
for i in $(seq 1 3); do
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: team-$i-config
  labels:
    app: demo
    team: "team-$i"
data:
  environment: "staging"
  team_name: "team-$i"
  deploy_target: "namespace-team-$i"
EOF
done

echo "Created 3 team ConfigMaps."
echo "Refresh the Dashboard to see all 5 ConfigMaps listed."
```

## Benefits of Dashboard extensions

```bash
echo "=== Why Use Dashboard Extensions ==="
echo ""
echo "1. Single pane of glass:"
echo "   View Tekton resources AND related config in one UI"
echo ""
echo "2. Team-friendly:"
echo "   Developers see Pipeline configs without kubectl access"
echo ""
echo "3. Audit visibility:"
echo "   Track configuration alongside Pipeline execution history"
echo ""
echo "4. Custom CRDs:"
echo "   Display your organization's custom resources"
echo "   (e.g., ApplicationDeployment, FeatureFlag CRDs)"
```

## Verify

Confirm the ConfigMaps exist:

```bash
kubectl get configmap -l app=demo -o name | wc -l | tr -d ' '
```
