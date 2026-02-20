# Build a custom interceptor service

Now let's build a custom interceptor as a Python Flask HTTP service. This
interceptor will:

1. Validate that a custom `X-Team-Token` header is present
2. Add a `priority` extension field based on the event body
3. Reject events without the required header

## Create the interceptor code

```bash
cat <<'PYEOF' > /tmp/interceptor.py
from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/', methods=['POST'])
def intercept():
    """Custom interceptor: validates team token and computes priority."""
    data = request.get_json(force=True)

    # Extract the original event headers
    headers = data.get('header', {})
    body = data.get('body', '{}')

    # Parse the event body
    try:
        if isinstance(body, str):
            event = json.loads(body)
        else:
            event = body
    except json.JSONDecodeError:
        event = {}

    # Validation: check for X-Team-Token header
    team_tokens = headers.get('X-Team-Token', headers.get('x-team-token', []))
    if not team_tokens or team_tokens[0] == '':
        return jsonify({
            'continue': False,
            'status': {
                'code': 403,
                'message': 'Rejected: missing X-Team-Token header'
            }
        })

    # Compute priority based on event content
    severity = event.get('severity', 'normal')
    if severity in ('critical', 'high'):
        priority = 'high'
    else:
        priority = 'normal'

    # Return success with extensions
    return jsonify({
        'extensions': {
            'validated': True,
            'team': team_tokens[0],
            'priority': priority
        },
        'continue': True,
        'status': {
            'code': 200
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYEOF
```

## Create a Dockerfile

```bash
cat <<'DOCKERFILE' > /tmp/Dockerfile.interceptor
FROM python:3.11-slim
RUN pip install --no-cache-dir flask
COPY interceptor.py /app/interceptor.py
WORKDIR /app
CMD ["python", "interceptor.py"]
DOCKERFILE
```

## Deploy using a ConfigMap and a generic Python image

Since we cannot build Docker images directly, we will deploy the interceptor
using a ConfigMap and a Python image:

```bash
kubectl create configmap interceptor-code \
  --from-file=interceptor.py=/tmp/interceptor.py

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: custom-interceptor
  labels:
    app: custom-interceptor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: custom-interceptor
  template:
    metadata:
      labels:
        app: custom-interceptor
    spec:
      containers:
        - name: interceptor
          image: python:3.11-slim
          command: ["sh", "-c", "pip install flask && python /app/interceptor.py"]
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: code
              mountPath: /app
      volumes:
        - name: code
          configMap:
            name: interceptor-code
---
apiVersion: v1
kind: Service
metadata:
  name: custom-interceptor
spec:
  selector:
    app: custom-interceptor
  ports:
    - port: 8080
      targetPort: 8080
EOF
```

## Wait for the interceptor to be ready

```bash
kubectl wait --for=condition=available deployment/custom-interceptor --timeout=120s
echo "Custom interceptor service is running!"
kubectl get pod -l app=custom-interceptor
```

## Verify

Confirm the interceptor pod is running:

```bash
kubectl get pod -l app=custom-interceptor -o jsonpath='{.items[0].status.phase}'
echo ""
```
