# Migration patterns and gotchas

Let's cover common patterns and pitfalls when migrating from Jenkins to Tekton.

## Workspace handling (Jenkins stash/unstash)

```bash
echo "=== Workspace Pattern ==="
echo ""
echo "Jenkins:"
echo "  stash includes: 'build/**', name: 'build-artifacts'"
echo "  unstash 'build-artifacts'"
echo ""
echo "Tekton:"
echo "  Use a shared Workspace (PVC or emptyDir)"
echo "  All Tasks in the Pipeline can access the same workspace"
echo "  No explicit stash/unstash needed"
```

## Secret management

```bash
echo "=== Secret Management ==="
echo ""
echo "Jenkins:"
echo "  withCredentials([usernamePassword(...)]) { ... }"
echo ""
echo "Tekton:"
echo "  1. Create Kubernetes Secret"
echo "  2. Mount as env var or volume in Task step"
echo "  3. Or use Vault Agent Injector (see Vault tutorial)"

cat <<SECRETEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: with-secret
spec:
  steps:
    - name: use-secret
      image: alpine:3.19
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: my-secret
              key: password
              optional: true
      script: |
        #!/usr/bin/env sh
        echo "Jenkins: withCredentials([...]) { sh ... }"
        echo "Tekton: Secret mounted as env var"
        echo "Password available as \\\$DB_PASSWORD"
SECRETEOF
```

## Verify the migrated Pipeline ran

```bash
kubectl get pipelinerun -l tekton.dev/pipeline=migrated-pipeline -o name | head -1
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=migrated-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
echo "Pipeline status: $STATUS"
```

## Verify

```bash
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=migrated-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
[ "$STATUS" = "True" ]
```
