# Understand multi-tenant Tekton

Tekton Pipelines runs as a **single controller** serving all namespaces in a cluster.
When multiple teams share the same cluster, each team needs its own namespace where
they can run Pipelines independently.

## Create team namespaces

Let's create namespaces for two separate teams:

```bash
kubectl create namespace team-a
kubectl create namespace team-b
kubectl create namespace team-c

echo ""
echo "=== Team Namespaces ==="
kubectl get namespaces team-a team-b team-c
```

## Verify Tekton works across namespaces

Create a simple Task in each namespace to confirm Tekton serves all of them:

```bash
for NS in team-a team-b team-c; do
cat <<EOF | kubectl apply -n "$NS" -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
spec:
  steps:
    - name: greet
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Hello from namespace: $NS"
EOF
done

echo ""
echo "=== Tasks across namespaces ==="
for NS in team-a team-b team-c; do
  echo "  $NS: $(kubectl get task -n "$NS" -o name 2>/dev/null | wc -l) task(s)"
done
```

## Understand the isolation problem

Right now, any ServiceAccount in any namespace can see resources in other namespaces
if it has cluster-level permissions. Without RBAC, team-a could list team-b's
PipelineRuns. In the next step, we will lock this down.

## Verify

```bash
kubectl get namespace team-a team-b team-c &>/dev/null && echo "All namespaces exist"
```
