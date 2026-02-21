# Configure RBAC for namespace isolation

Each team should only be able to manage Tekton resources in their own namespace.
We will create a **ServiceAccount**, **Role**, and **RoleBinding** per team.

## Create the Tekton team Role

This Role grants full access to Tekton Pipeline resources within a namespace:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tekton-team-role
rules:
  - apiGroups: ["tekton.dev"]
    resources: ["tasks", "taskruns", "pipelines", "pipelineruns"]
    verbs: ["get", "list", "watch", "create", "update", "delete"]
  - apiGroups: [""]
    resources: ["pods", "pods/log", "configmaps", "secrets"]
    verbs: ["get", "list", "watch"]
EOF

echo "ClusterRole tekton-team-role created"
```

## Create per-team ServiceAccounts and RoleBindings

```bash
for NS in team-a team-b team-c; do
  # Create ServiceAccount
  kubectl create serviceaccount "${NS}-sa" -n "$NS"

  # Bind the ClusterRole to this SA, scoped to the team's namespace only
  kubectl create rolebinding "${NS}-tekton-binding" \
    --clusterrole=tekton-team-role \
    --serviceaccount="${NS}:${NS}-sa" \
    --namespace="$NS"
done

echo ""
echo "=== RBAC Configuration ==="
for NS in team-a team-b team-c; do
  echo "  $NS:"
  echo "    SA: $(kubectl get sa "${NS}-sa" -n "$NS" -o name)"
  echo "    Binding: $(kubectl get rolebinding "${NS}-tekton-binding" -n "$NS" -o name)"
done
```

## Test isolation

Show that team-a's ServiceAccount cannot access team-b's resources:

```bash
echo "=== Testing namespace isolation ==="

echo ""
echo "team-a SA listing tasks in team-a (should work):"
kubectl auth can-i list tasks.tekton.dev \
  --namespace=team-a --as=system:serviceaccount:team-a:team-a-sa

echo ""
echo "team-a SA listing tasks in team-b (should be denied):"
kubectl auth can-i list tasks.tekton.dev \
  --namespace=team-b --as=system:serviceaccount:team-a:team-a-sa

echo ""
echo "team-b SA listing tasks in team-b (should work):"
kubectl auth can-i list tasks.tekton.dev \
  --namespace=team-b --as=system:serviceaccount:team-b:team-b-sa
```

## Verify

```bash
kubectl get rolebinding team-a-tekton-binding -n team-a &>/dev/null && \
kubectl get rolebinding team-b-tekton-binding -n team-b &>/dev/null && \
echo "RBAC configured"
```
