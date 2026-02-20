# Enable beta features

Let's enable beta API fields and verify that beta features like Matrix become
available.

## Enable beta API fields

```bash
kubectl patch configmap feature-flags -n tekton-pipelines \
  -p '{"data":{"enable-api-fields":"beta"}}'
```

Restart the Pipeline controller to apply:

```bash
kubectl delete pod -l app=tekton-pipelines-controller -n tekton-pipelines
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=120s
```

## Verify beta is enabled

```bash
API_FIELDS=$(kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.enable-api-fields}')
echo "enable-api-fields: $API_FIELDS"
```

## Test a beta feature: Matrix

Create a Pipeline that uses the Matrix feature (beta):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: platform-test
spec:
  params:
    - name: platform
      type: string
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Testing on platform: \$(params.platform)"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: beta-matrix-demo
spec:
  tasks:
    - name: test-platforms
      taskRef:
        name: platform-test
      matrix:
        params:
          - name: platform
            value:
              - "linux"
              - "darwin"
              - "windows"
EOF
```

Run the Pipeline with Matrix:

```bash
tkn pipeline start beta-matrix-demo --showlog
```

The Pipeline should fan out into 3 TaskRuns (one per platform). This would fail
if `enable-api-fields` were set to `stable`.

## Verify

Confirm beta features are enabled and the Matrix Pipeline exists:

```bash
kubectl get configmap feature-flags -n tekton-pipelines \
  -o jsonpath='{.data.enable-api-fields}' | grep -q beta
```
