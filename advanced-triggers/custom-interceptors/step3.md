# Register and use the custom interceptor

Now that the interceptor service is running, we need to register it as a
**ClusterInterceptor** so Tekton Triggers can use it.

## Create the ClusterInterceptor

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1alpha1
kind: ClusterInterceptor
metadata:
  name: team-validator
spec:
  clientConfig:
    url: "http://custom-interceptor.default.svc.cluster.local:8080"
EOF
```

This tells Triggers: "There is an interceptor called `team-validator` accessible
at the custom-interceptor service."

## Create TriggerBinding and TriggerTemplate

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: interceptor-binding
spec:
  params:
    - name: message
      value: \$(body.message)
    - name: priority
      value: \$(extensions.priority)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: interceptor-template
spec:
  params:
    - name: message
    - name: priority
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: interceptor-demo-
      spec:
        pipelineRef:
          name: interceptor-demo
        params:
          - name: message
            value: \$(tt.params.message)
          - name: priority
            value: \$(tt.params.priority)
EOF
```

Notice how the TriggerBinding reads `$(extensions.priority)` -- this is the field
our custom interceptor adds in its response.

## Create the EventListener with the custom interceptor

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: custom-interceptor-listener
spec:
  serviceAccountName: default
  triggers:
    - name: team-validated-trigger
      interceptors:
        - ref:
            name: team-validator
            kind: ClusterInterceptor
      bindings:
        - ref: interceptor-binding
      template:
        ref: interceptor-template
EOF
```

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=available deployment -l eventlistener=custom-interceptor-listener --timeout=120s
echo "EventListener is ready!"
```

## Verify

Confirm the ClusterInterceptor exists:

```bash
kubectl get clusterinterceptor team-validator
```
