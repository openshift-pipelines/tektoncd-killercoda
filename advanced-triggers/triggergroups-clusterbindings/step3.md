# Scale triggers across namespaces

The real power of ClusterTriggerBindings shows when multiple teams use them from
different namespaces.

## Create team namespaces

```bash
kubectl create namespace team-frontend
kubectl create namespace team-backend
```

## Deploy Tekton resources in each namespace

Create Tasks and TriggerTemplates in each team namespace:

```bash
for TEAM_NS in team-frontend team-backend; do
  cat <<EOF | kubectl apply -n $TEAM_NS -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: team-build
spec:
  params:
    - name: git-repo
      type: string
    - name: git-branch
      type: string
    - name: git-commit
      type: string
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Team: ${TEAM_NS}"
        echo "  Building from: \$(params.git-repo)"
        echo "  Branch: \$(params.git-branch)"
        echo "  Commit: \$(params.git-commit)"
        echo "========================================="
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: team-template
spec:
  params:
    - name: git-repo
    - name: git-commit
    - name: git-branch
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: TaskRun
      metadata:
        generateName: team-build-
      spec:
        taskRef:
          name: team-build
        params:
          - name: git-repo
            value: \$(tt.params.git-repo)
          - name: git-commit
            value: \$(tt.params.git-commit)
          - name: git-branch
            value: \$(tt.params.git-branch)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: team-listener
spec:
  serviceAccountName: default
  triggers:
    - name: team-push
      bindings:
        - kind: ClusterTriggerBinding
          ref: common-git-fields
      template:
        ref: team-template
EOF
done
```

## Verify both teams share the same ClusterTriggerBinding

```bash
echo "=== Shared ClusterTriggerBindings ==="
kubectl get clustertriggerbinding

echo ""
echo "=== team-frontend resources ==="
kubectl get eventlistener,triggerbinding,triggertemplate -n team-frontend

echo ""
echo "=== team-backend resources ==="
kubectl get eventlistener,triggerbinding,triggertemplate -n team-backend
```

## The multi-tenant pattern

```bash
echo "=== Multi-Tenant Trigger Pattern ==="
echo ""
echo "Cluster-scoped (shared by all teams):"
echo "  - ClusterTriggerBinding: common-git-fields"
echo "  - ClusterTriggerBinding: common-sender-fields"
echo ""
echo "Namespace-scoped (per team):"
echo "  - team-frontend/EventListener"
echo "  - team-frontend/TriggerTemplate"
echo "  - team-frontend/Task (team-build)"
echo ""
echo "  - team-backend/EventListener"
echo "  - team-backend/TriggerTemplate"
echo "  - team-backend/Task (team-build)"
echo ""
echo "This pattern avoids duplicating binding definitions while keeping"
echo "PipelineRuns isolated per namespace."
```

## Verify

Confirm triggers exist in multiple namespaces:

```bash
kubectl get eventlistener -n team-frontend && kubectl get eventlistener -n team-backend
```
