# View Triggers resources in Dashboard

The Dashboard automatically detects Tekton Triggers and displays its resources.

## Access the Dashboard

<!-- e2e-skip -->
```bash
kubectl port-forward svc/tekton-dashboard -n tekton-pipelines 9097:9097 &>/dev/null &
echo "Dashboard available at: http://localhost:9097"
```

## Create Triggers resources

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: handle-event
spec:
  params:
    - name: event-type
      type: string
  steps:
    - name: handle
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Handling event: \$(params.event-type)"
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: event-binding
spec:
  params:
    - name: event-type
      value: \$(body.type)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: event-template
spec:
  params:
    - name: event-type
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: TaskRun
      metadata:
        generateName: handle-event-
      spec:
        taskRef:
          name: handle-event
        params:
          - name: event-type
            value: \$(tt.params.event-type)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: dashboard-demo-listener
spec:
  serviceAccountName: default
  triggers:
    - name: event-trigger
      bindings:
        - ref: event-binding
      template:
        ref: event-template
EOF

kubectl wait --for=condition=available deployment -l eventlistener=dashboard-demo-listener --timeout=120s
```

## View in Dashboard

```bash
echo "In the Dashboard UI, you should see:"
echo "  - EventListeners: dashboard-demo-listener"
echo "  - TriggerBindings: event-binding"
echo "  - TriggerTemplates: event-template"
```

## Verify

```bash
kubectl get eventlistener dashboard-demo-listener &>/dev/null
```
