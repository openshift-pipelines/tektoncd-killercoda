# Use TriggerGroups for multi-trigger EventListeners

TriggerGroups let you organize triggers by purpose within an EventListener.
Instead of a flat list of triggers, you group them logically.

## Create an EventListener with organized triggers

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: multi-trigger-listener
spec:
  serviceAccountName: default
  triggers:
    - name: push-trigger
      interceptors:
        - ref:
            name: cel
          params:
            - name: filter
              value: "body.ref.startsWith('refs/heads/')"
      bindings:
        - kind: ClusterTriggerBinding
          ref: common-git-fields
      template:
        ref: shared-template
    - name: tag-trigger
      interceptors:
        - ref:
            name: cel
          params:
            - name: filter
              value: "body.ref.startsWith('refs/tags/')"
      bindings:
        - kind: ClusterTriggerBinding
          ref: common-git-fields
      template:
        ref: shared-template
EOF
```

Notice how both triggers reference the **ClusterTriggerBinding** `common-git-fields`
using `kind: ClusterTriggerBinding`. This is the key syntax -- without `kind`,
Triggers assumes a namespace-scoped TriggerBinding.

## Wait for the EventListener

```bash
kubectl wait --for=condition=available deployment \
  -l eventlistener=multi-trigger-listener --timeout=120s
echo "EventListener ready!"
```

## Test with a branch push event

```bash
kubectl port-forward svc/$(kubectl get svc -l eventlistener=multi-trigger-listener \
  -o jsonpath='{.items[0].metadata.name}') 8090:8080 &>/dev/null &
PF_PID=$!
sleep 2

echo "Sending branch push event..."
curl -s -X POST http://localhost:8090 \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "refs/heads/main",
    "head_commit": {"id": "abc123"},
    "repository": {"full_name": "org/repo"},
    "sender": {"login": "developer", "type": "User"}
  }'

echo ""
echo "Sending tag push event..."
curl -s -X POST http://localhost:8090 \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "refs/tags/v1.0.0",
    "head_commit": {"id": "def456"},
    "repository": {"full_name": "org/repo"},
    "sender": {"login": "release-bot", "type": "Bot"}
  }'

kill $PF_PID 2>/dev/null
echo ""
```

## Check the results

```bash
sleep 10
echo "=== TaskRuns created ==="
kubectl get taskrun
echo ""
echo "Both events used the same ClusterTriggerBinding but matched different triggers."
```

## Verify

Confirm the EventListener with multiple triggers exists:

```bash
kubectl get eventlistener multi-trigger-listener -o jsonpath='{.spec.triggers[*].name}'
echo ""
```
