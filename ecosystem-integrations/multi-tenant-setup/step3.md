# Shared resources with Cluster-scoped objects

While namespaces isolate teams, some Tasks should be shared across all teams.
Tekton supports this with **cluster-scoped resolvers** and shared resources.

## Create a shared ClusterRole for read-only access to cluster Tasks

Use a **Cluster Resolver** to share Tasks from a central namespace:

```bash
# Create a shared-tasks namespace for common resources
kubectl create namespace shared-tasks

# Create a common Task in the shared namespace
cat <<'EOF' | kubectl apply -n shared-tasks -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: shared-lint
spec:
  params:
    - name: message
      type: string
      default: "Running shared linter"
  steps:
    - name: lint
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "$(params.message)"
        echo "Linting passed!"
EOF

echo "Shared Task created in shared-tasks namespace"
```

## Apply ResourceQuotas per team

Limit resource usage to ensure fair allocation:

```bash
for NS in team-a team-b team-c; do
cat <<EOF | kubectl apply -n "$NS" -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tekton-quota
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: "2Gi"
    limits.cpu: "4"
    limits.memory: "4Gi"
EOF
done

echo ""
echo "=== Resource Quotas ==="
for NS in team-a team-b team-c; do
  echo "  $NS: $(kubectl get resourcequota tekton-quota -n "$NS" -o jsonpath='{.spec.hard.pods}') pods max"
done
```

## Run a Pipeline using cluster resolver

Each team can reference the shared Task using the cluster resolver:

```bash
cat <<'EOF' | kubectl apply -n team-a -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: team-pipeline
spec:
  tasks:
    - name: team-task
      taskSpec:
        steps:
          - name: work
            image: alpine:3.19
            script: |
              #!/usr/bin/env sh
              echo "Team-A doing their own work"
    - name: shared-step
      runAfter: ["team-task"]
      taskRef:
        resolver: cluster
        params:
          - name: kind
            value: task
          - name: name
            value: shared-lint
          - name: namespace
            value: shared-tasks
EOF

echo ""
echo "=== Team-A Pipeline (uses shared task from shared-tasks namespace) ==="
kubectl get pipeline team-pipeline -n team-a
```

## Summary of the multi-tenant pattern

```bash
echo "=== Multi-Tenant Architecture ==="
echo ""
echo "shared-tasks (central):"
echo "  - Common Tasks (shared-lint, etc.)"
echo "  - Accessed via cluster resolver"
echo ""
for NS in team-a team-b team-c; do
  echo "$NS (isolated):"
  echo "  - Own ServiceAccount + RoleBinding"
  echo "  - Own ResourceQuota"
  echo "  - Can reference shared-tasks via resolver"
  echo ""
done
```

## Verify

```bash
kubectl get resourcequota tekton-quota -n team-a &>/dev/null && \
kubectl get task shared-lint -n shared-tasks &>/dev/null && \
echo "Multi-tenant setup complete"
```
