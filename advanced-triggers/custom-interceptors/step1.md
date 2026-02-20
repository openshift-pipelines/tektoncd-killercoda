# Understand the interceptor HTTP protocol

Before building a custom interceptor, let's understand the protocol it must
implement.

## The InterceptorRequest format

When Triggers calls your interceptor, it sends a POST request with this JSON
structure:

```bash
echo '{
  "body": "... the raw webhook event body ...",
  "header": {
    "Content-Type": ["application/json"],
    "X-Custom-Header": ["some-value"]
  },
  "extensions": {},
  "interceptor_params": {
    "param1": "value1"
  },
  "context": {
    "event_url": "/api/v1/webhooks",
    "event_id": "abc-123",
    "trigger_id": "my-trigger"
  }
}' | python3 -m json.tool
```

Key fields:

- **body**: The original webhook payload (e.g., GitHub push event JSON)
- **header**: HTTP headers from the incoming request
- **extensions**: Data added by previous interceptors in the chain
- **interceptor_params**: Parameters configured in the EventListener

## The InterceptorResponse format

Your interceptor returns one of two responses:

**Success** -- continue processing:

```bash
echo '{
  "extensions": {
    "validated": true,
    "priority": "high",
    "computed-field": "derived-value"
  },
  "continue": true,
  "status": {
    "code": 200
  }
}' | python3 -m json.tool
```

**Rejection** -- stop processing:

```bash
echo '{
  "continue": false,
  "status": {
    "code": 403,
    "message": "Event rejected: missing required header"
  }
}' | python3 -m json.tool
```

## Set up the foundation

Create a Pipeline that will be triggered by events passing through our custom
interceptor:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: interceptor-demo
spec:
  params:
    - name: message
      type: string
    - name: priority
      type: string
      default: "normal"
  tasks:
    - name: process
      taskRef:
        name: echo-event
      params:
        - name: message
          value: "\$(params.message)"
        - name: priority
          value: "\$(params.priority)"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: echo-event
spec:
  params:
    - name: message
      type: string
    - name: priority
      type: string
  steps:
    - name: echo
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Event Processed"
        echo "  Message:  \$(params.message)"
        echo "  Priority: \$(params.priority)"
        echo "========================================="
EOF
```

## Verify

Confirm the Pipeline and Task exist:

```bash
kubectl get pipeline interceptor-demo
kubectl get task echo-event
```
