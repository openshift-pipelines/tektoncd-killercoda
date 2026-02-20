# Query metrics in Prometheus

Now let's configure Prometheus to scrape Tekton metrics and run some PromQL
queries.

## Configure Prometheus to scrape Tekton

Prometheus needs to know where to find the Tekton metrics endpoint. We need
to create a ServiceMonitor or add a scrape config. For this tutorial, we
will create a Kubernetes Service that exposes the Tekton controller metrics
and annotate it so Prometheus discovers it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: tekton-metrics
  namespace: tekton-pipelines
  labels:
    app: tekton-metrics
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
spec:
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/part-of: tekton-pipelines
  ports:
    - name: metrics
      port: 9090
      targetPort: 9090
      protocol: TCP
EOF
```

Verify the service is created:

```bash
kubectl get svc tekton-metrics -n tekton-pipelines
```

## Access the Prometheus UI

Port-forward the Prometheus server:

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
```

```bash
sleep 3
```

## Run PromQL queries

Now we can query Prometheus directly using its HTTP API. Let's start with
some basic queries.

**Total TaskRun count:**

```bash
curl -s "http://localhost:9090/api/v1/query?query=tekton_pipelines_controller_taskrun_count" | python3 -m json.tool
```

**Currently running PipelineRuns:**

```bash
curl -s "http://localhost:9090/api/v1/query?query=tekton_pipelines_controller_running_pipelineruns_count" | python3 -m json.tool
```

## Generate PipelineRun data for richer metrics

Let's create a Pipeline and run it several times:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: metrics-pipeline
spec:
  tasks:
    - name: step-one
      taskRef:
        name: metrics-demo
    - name: step-two
      taskRef:
        name: metrics-demo
      runAfter:
        - step-one
EOF
```

Run it multiple times to create a statistical sample:

```bash
for i in 1 2 3 4 5; do
  cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: metrics-pipeline-run-
spec:
  pipelineRef:
    name: metrics-pipeline
EOF
  sleep 3
done
```

Wait for all runs to complete:

```bash
sleep 60
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=metrics-pipeline --timeout=180s
```

## Query PipelineRun duration

Now query the PipelineRun duration histogram to see how long runs take:

```bash
curl -s "http://localhost:9090/api/v1/query?query=tekton_pipelines_controller_pipelinerun_duration_seconds_count" | python3 -m json.tool
```

**Average PipelineRun duration over the last 5 minutes:**

```bash
curl -s "http://localhost:9090/api/v1/query?query=rate(tekton_pipelines_controller_pipelinerun_duration_seconds_sum[5m])/rate(tekton_pipelines_controller_pipelinerun_duration_seconds_count[5m])" | python3 -m json.tool
```

These are the same PromQL queries you would use in a Grafana dashboard panel.
