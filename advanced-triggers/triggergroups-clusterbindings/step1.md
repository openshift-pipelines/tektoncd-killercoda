# Create ClusterTriggerBindings for shared bindings

ClusterTriggerBindings are cluster-scoped (not namespace-scoped), meaning any
EventListener in any namespace can reference them.

## Namespace-scoped vs Cluster-scoped bindings

```bash
echo "=== TriggerBinding (namespace-scoped) ==="
echo "  - Lives in a specific namespace"
echo "  - Only EventListeners in that namespace can use it"
echo "  - Good for team-specific fields"
echo ""
echo "=== ClusterTriggerBinding (cluster-scoped) ==="
echo "  - Available to ALL namespaces"
echo "  - Shared configuration for common event fields"
echo "  - Good for standard fields like repo, commit, branch"
```

## Create ClusterTriggerBindings for common fields

These bindings extract standard webhook fields that every team needs:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: ClusterTriggerBinding
metadata:
  name: common-git-fields
spec:
  params:
    - name: git-repo
      value: \$(body.repository.full_name)
    - name: git-commit
      value: \$(body.head_commit.id)
    - name: git-branch
      value: \$(body.ref)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: ClusterTriggerBinding
metadata:
  name: common-sender-fields
spec:
  params:
    - name: sender-name
      value: \$(body.sender.login)
    - name: sender-type
      value: \$(body.sender.type)
EOF
```

## Create a Task and TriggerTemplate that use these fields

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: log-event
spec:
  params:
    - name: git-repo
      type: string
    - name: git-commit
      type: string
    - name: git-branch
      type: string
  steps:
    - name: log
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Git Event Received"
        echo "  Repo:   \$(params.git-repo)"
        echo "  Commit: \$(params.git-commit)"
        echo "  Branch: \$(params.git-branch)"
        echo "========================================="
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: shared-template
spec:
  params:
    - name: git-repo
    - name: git-commit
    - name: git-branch
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: TaskRun
      metadata:
        generateName: git-event-
      spec:
        taskRef:
          name: log-event
        params:
          - name: git-repo
            value: \$(tt.params.git-repo)
          - name: git-commit
            value: \$(tt.params.git-commit)
          - name: git-branch
            value: \$(tt.params.git-branch)
EOF
```

## Verify

Confirm the ClusterTriggerBindings exist:

```bash
kubectl get clustertriggerbinding
```
