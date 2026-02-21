# Debug failed triggers in Dashboard

Let's create a misconfigured trigger and use the Dashboard to diagnose it.

## Create a broken binding

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: broken-binding
spec:
  params:
    - name: nonexistent-field
      value: \$(body.this.path.does.not.exist)
EOF
```

## Check EventListener logs

```bash
echo "=== EventListener Logs ==="
kubectl logs -l eventlistener=dashboard-demo-listener --tail=20
echo ""
echo "In the Dashboard, navigate to EventListeners > dashboard-demo-listener"
echo "to see status and error information."
```

## Verify

```bash
kubectl get triggerbinding broken-binding &>/dev/null
```
