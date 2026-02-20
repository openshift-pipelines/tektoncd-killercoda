# Create a basic EventListener with CEL filter

Let's set up a complete Triggers configuration with a CEL interceptor that
filters for push events only.

## Create RBAC resources

The EventListener needs permissions to create PipelineRuns:

```bash
kubectl create serviceaccount tekton-triggers-sa
```

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-binding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-clusterbinding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
EOF
```

## Create a Pipeline to trigger

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: log-event
spec:
  params:
    - name: action
      type: string
    - name: repo-name
      type: string
  steps:
    - name: log
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "============================="
        echo "Event received!"
        echo "Action: $(params.action)"
        echo "Repository: $(params.repo-name)"
        echo "============================="
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: cel-demo-pipeline
spec:
  params:
    - name: action
      type: string
    - name: repo-name
      type: string
  tasks:
    - name: log-event
      taskRef:
        name: log-event
      params:
        - name: action
          value: $(params.action)
        - name: repo-name
          value: $(params.repo-name)
EOF
```

## Create TriggerBinding and TriggerTemplate

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: cel-demo-binding
spec:
  params:
    - name: action
      value: $(body.action)
    - name: repo-name
      value: $(body.repository.name)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: cel-demo-template
spec:
  params:
    - name: action
    - name: repo-name
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: cel-demo-run-
      spec:
        pipelineRef:
          name: cel-demo-pipeline
        params:
          - name: action
            value: $(tt.params.action)
          - name: repo-name
            value: $(tt.params.repo-name)
EOF
```

## Create the EventListener with a CEL filter

Here is the key part -- the **CEL interceptor** with a `filter` expression. This
EventListener only accepts events where `body.action == "push"`:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: cel-demo
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: cel-filtered-trigger
      interceptors:
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.action == 'push'"
      bindings:
        - ref: cel-demo-binding
      template:
        ref: cel-demo-template
EOF
```

The `filter` parameter is a CEL expression that must evaluate to `true` for the
event to proceed. If it evaluates to `false`, the event is silently dropped.

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=ready eventlistener cel-demo --timeout=60s
```

Verify the EventListener Service was created:

```bash
kubectl get service el-cel-demo
```

The EventListener is now running and filtering for push events only.
