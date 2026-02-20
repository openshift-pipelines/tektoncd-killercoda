# Understand interceptor ordering

In this step, you will create an EventListener with **two CEL interceptors** in
a chain: the first filters events by type, and the second transforms the
payload with overlays. This demonstrates that interceptors execute in sequence,
and each one can modify the event body for the next.

## Set up RBAC

The EventListener needs permissions to create resources:

```bash
kubectl create serviceaccount tekton-triggers-sa
```

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: triggers-role-binding
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
  name: triggers-cluster-binding
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
  name: print-event-info
spec:
  params:
    - name: event-type
      type: string
    - name: repo-name
      type: string
    - name: timestamp
      type: string
  steps:
    - name: print
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "================================="
        echo "Event processed by chained interceptors"
        echo "Event Type: $(params.event-type)"
        echo "Repository: $(params.repo-name)"
        echo "Timestamp:  $(params.timestamp)"
        echo "================================="
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: interceptor-chain-demo
spec:
  params:
    - name: event-type
      type: string
    - name: repo-name
      type: string
    - name: timestamp
      type: string
  tasks:
    - name: print-info
      taskRef:
        name: print-event-info
      params:
        - name: event-type
          value: $(params.event-type)
        - name: repo-name
          value: $(params.repo-name)
        - name: timestamp
          value: $(params.timestamp)
EOF
```

## Create TriggerBinding and TriggerTemplate

The TriggerBinding reads fields from the event body - including fields added
by CEL overlays:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: chain-demo-binding
spec:
  params:
    - name: event-type
      value: $(body.event_type)
    - name: repo-name
      value: $(body.repository.name)
    - name: timestamp
      value: $(body.processed_at)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: chain-demo-template
spec:
  params:
    - name: event-type
    - name: repo-name
    - name: timestamp
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: chain-demo-run-
      spec:
        pipelineRef:
          name: interceptor-chain-demo
        params:
          - name: event-type
            value: $(tt.params.event-type)
          - name: repo-name
            value: $(tt.params.repo-name)
          - name: timestamp
            value: $(tt.params.timestamp)
EOF
```

## Create the EventListener with two chained CEL interceptors

Here is the key concept - **two CEL interceptors in order**:

1. **Filter**: Only accepts events where `body.event_type == "push"`
2. **Overlay**: Adds a `processed_at` field to the event body

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: chain-demo
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: chained-interceptors
      interceptors:
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.event_type == 'push'"
        - ref:
            name: "cel"
          params:
            - name: "overlays"
              value:
                - key: processed_at
                  expression: "'processed-by-chain'"
      bindings:
        - ref: chain-demo-binding
      template:
        ref: chain-demo-template
EOF
```

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=ready eventlistener chain-demo --timeout=60s
kubectl get service el-chain-demo
```

## Test: send a push event (should trigger)

```bash
curl -X POST http://$(kubectl get service el-chain-demo -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -d '{"event_type": "push", "repository": {"name": "my-repo", "url": "https://github.com/example/my-repo"}}'
```

Check that a PipelineRun was created:

```bash
sleep 3
tkn pipelinerun list
```

## Test: send a pull_request event (should be filtered out)

```bash
curl -X POST http://$(kubectl get service el-chain-demo -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -d '{"event_type": "pull_request", "repository": {"name": "my-repo"}}'
```

No new PipelineRun should appear because the first CEL interceptor filtered it
out:

```bash
sleep 3
tkn pipelinerun list
```

You should still see only the one PipelineRun from the push event. The
`pull_request` event was dropped by the first interceptor in the chain.
