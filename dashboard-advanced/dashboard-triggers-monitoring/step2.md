# Monitor webhook-triggered PipelineRuns

Let's trigger events and watch TaskRuns appear in the Dashboard.

## Send an event

```bash
kubectl port-forward svc/$(kubectl get svc -l eventlistener=dashboard-demo-listener \
  -o jsonpath='{.items[0].metadata.name}') 8090:8080 &>/dev/null &
PF_PID=$!
sleep 2

echo "Sending webhook event..."
curl -s -X POST http://localhost:8090 \
  -H "Content-Type: application/json" \
  -d '{"type": "push", "repo": "my-app"}'

kill $PF_PID 2>/dev/null
echo ""
echo "Event sent! Check the Dashboard for a new TaskRun."
```

## Watch in Dashboard

```bash
sleep 10
echo "=== TaskRuns created by webhook ==="
kubectl get taskrun
echo ""
echo "In the Dashboard, navigate to TaskRuns to see the new run."
```

## Send more events

```bash
kubectl port-forward svc/$(kubectl get svc -l eventlistener=dashboard-demo-listener \
  -o jsonpath='{.items[0].metadata.name}') 8090:8080 &>/dev/null &
PF_PID=$!
sleep 2

for event in "tag" "release" "deploy"; do
  curl -s -X POST http://localhost:8090 \
    -H "Content-Type: application/json" \
    -d "{\"type\": \"$event\", \"repo\": \"my-app\"}"
  echo "Sent: $event"
done

kill $PF_PID 2>/dev/null
sleep 10
echo ""
kubectl get taskrun
```

## Verify

```bash
kubectl get taskrun -o name 2>/dev/null | grep -q taskrun
```
