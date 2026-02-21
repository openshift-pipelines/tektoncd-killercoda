# Enable OpenTelemetry in Tekton

Let's set up Jaeger and configure Tekton to export traces.

## Verify Jaeger is running

The install script deployed Jaeger all-in-one:

```bash
kubectl get pod -l app=jaeger -n tekton-pipelines
```

## Configure Tekton for tracing

Tekton uses a ConfigMap to configure the OpenTelemetry tracing endpoint:

```bash
kubectl patch configmap config-tracing -n tekton-pipelines -p '{"data":{
  "enabled": "true",
  "endpoint": "http://jaeger-collector.tekton-pipelines.svc.cluster.local:14268/api/traces"
}}'
```

## Restart the Pipeline controller

```bash
kubectl delete pod -l app=tekton-pipelines-controller -n tekton-pipelines
kubectl wait --for=condition=ready pod -l app=tekton-pipelines-controller \
  -n tekton-pipelines --timeout=120s
echo "Tracing enabled!"
```

## Make Jaeger UI accessible

```bash
kubectl port-forward svc/jaeger-query -n tekton-pipelines 16686:16686 &>/dev/null &
echo "Jaeger UI available at: http://localhost:16686"
echo ""
echo "On Killercoda, use the Traffic/Ports tab to access port 16686"
```

## Verify

Confirm Jaeger is accessible:

```bash
kubectl get svc jaeger-query -n tekton-pipelines
```
