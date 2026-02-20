# Configure RBAC for Dashboard access

Kubernetes RBAC controls what actions a user (or ServiceAccount) can perform
on which resources. We will create two roles:

- **dashboard-admin** - full access to create, modify, and delete Tekton
  resources
- **dashboard-viewer** - read-only access to Tekton resources

## Create a namespace for team isolation

```bash
kubectl create namespace team-alpha
```

## Create the admin ServiceAccount

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: team-alpha
---
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-admin-token
  namespace: team-alpha
  annotations:
    kubernetes.io/service-account.name: dashboard-admin
type: kubernetes.io/service-account-token
EOF
```

## Create the viewer ServiceAccount

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-viewer
  namespace: team-alpha
---
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-viewer-token
  namespace: team-alpha
  annotations:
    kubernetes.io/service-account.name: dashboard-viewer
type: kubernetes.io/service-account-token
EOF
```

## Create a ClusterRole for Tekton admins

This role grants full access to all Tekton resources:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tekton-admin
rules:
  - apiGroups: ["tekton.dev"]
    resources:
      - tasks
      - taskruns
      - pipelines
      - pipelineruns
      - clustertasks
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources:
      - pods
      - pods/log
      - configmaps
      - secrets
      - serviceaccounts
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources:
      - namespaces
    verbs: ["get", "list", "watch"]
EOF
```

## Create a ClusterRole for Tekton viewers

This role only grants read access:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tekton-viewer
rules:
  - apiGroups: ["tekton.dev"]
    resources:
      - tasks
      - taskruns
      - pipelines
      - pipelineruns
      - clustertasks
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources:
      - pods
      - pods/log
      - configmaps
      - serviceaccounts
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources:
      - namespaces
    verbs: ["get", "list", "watch"]
EOF
```

## Bind roles to ServiceAccounts

Bind the admin role to the `dashboard-admin` ServiceAccount in the
`team-alpha` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-admin-binding
  namespace: team-alpha
subjects:
  - kind: ServiceAccount
    name: dashboard-admin
    namespace: team-alpha
roleRef:
  kind: ClusterRole
  name: tekton-admin
  apiGroup: rbac.authorization.k8s.io
EOF
```

Bind the viewer role to the `dashboard-viewer` ServiceAccount:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-viewer-binding
  namespace: team-alpha
subjects:
  - kind: ServiceAccount
    name: dashboard-viewer
    namespace: team-alpha
roleRef:
  kind: ClusterRole
  name: tekton-viewer
  apiGroup: rbac.authorization.k8s.io
EOF
```

## Verify the RBAC configuration

Check that all roles and bindings were created:

```bash
echo "=== ClusterRoles ==="
kubectl get clusterrole tekton-admin tekton-viewer

echo ""
echo "=== RoleBindings in team-alpha ==="
kubectl get rolebinding -n team-alpha

echo ""
echo "=== ServiceAccounts in team-alpha ==="
kubectl get serviceaccount -n team-alpha
```

You should see both ClusterRoles, both RoleBindings, and both ServiceAccounts
listed. In the next step, we will test that these roles actually enforce
different levels of access.
