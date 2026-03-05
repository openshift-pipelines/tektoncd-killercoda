# Test the custom interceptor end-to-end

Let's send events through the EventListener and see our custom interceptor in
action.

## Get the EventListener URL

```bash
EL_URL=$(kubectl get eventlistener custom-interceptor-listener \
  -o jsonpath='{.status.address.url}')
echo "EventListener URL: $EL_URL"
```

## Test 1: Valid event with team token

Send an event with the required `X-Team-Token` header:

```bash
EL_POD=$(kubectl get pod -l eventlistener=custom-interceptor-listener -o name | head -1)
EL_URL="http://$(kubectl get svc -l eventlistener=custom-interceptor-listener -o jsonpath='{.items[0].metadata.name}'):8080"

curl -s -X POST "$EL_URL" \
  -H "Content-Type: application/json" \
  -H "X-Team-Token: team-alpha-secret" \
  -d '{"message": "Deploy to staging", "severity": "critical"}' \
  2>/dev/null && echo "Event accepted!" || echo "Sending event..."

# Alternative: use kubectl port-forward
kubectl port-forward svc/$(kubectl get svc -l eventlistener=custom-interceptor-listener \
  -o jsonpath='{.items[0].metadata.name}') 8090:8080 &>/dev/null &
PF_PID=$!

# Wait for port-forward to accept connections
for i in $(seq 1 30); do
  curl -s -o /dev/null -w '%{http_code}' http://localhost:8090 2>/dev/null && break
  sleep 2
done

curl -s -X POST http://localhost:8090 \
  -H "Content-Type: application/json" \
  -H "X-Team-Token: team-alpha-secret" \
  -d '{"message": "Deploy to staging", "severity": "critical"}'

kill $PF_PID 2>/dev/null
echo ""
```

## Test 2: Rejected event without team token

Send an event without the required header:

```bash
kubectl port-forward svc/$(kubectl get svc -l eventlistener=custom-interceptor-listener \
  -o jsonpath='{.items[0].metadata.name}') 8090:8080 &>/dev/null &
PF_PID=$!

# Wait for port-forward to accept connections
for i in $(seq 1 30); do
  curl -s -o /dev/null -w '%{http_code}' http://localhost:8090 2>/dev/null && break
  sleep 2
done

echo "Sending event WITHOUT X-Team-Token header (should be rejected):"
curl -s -X POST http://localhost:8090 \
  -H "Content-Type: application/json" \
  -d '{"message": "Unauthorized deploy", "severity": "normal"}'

kill $PF_PID 2>/dev/null
echo ""
```

## Check the results

Wait for the PipelineRun to be created (only from the valid event):

```bash
sleep 10
echo "=== PipelineRuns created ==="
kubectl get pipelinerun
echo ""
echo "Only the event with X-Team-Token should have created a PipelineRun."
echo "The event without the header should have been rejected by the interceptor."
```

Check the interceptor logs:

```bash
echo "=== Interceptor Logs ==="
kubectl logs -l app=custom-interceptor --tail=20
```

## Verify

Confirm a PipelineRun was created from the valid event:

```bash
kubectl get pipelinerun -o name 2>/dev/null | grep -q pipelinerun
```
