# Explore Tekton's built-in metrics

The Tekton Pipelines controller exposes Prometheus metrics at port 9090 on
the `/metrics` endpoint. These metrics are available without any additional
configuration -- they are built into Tekton.

## View the metrics endpoint

First, let's port-forward the Tekton Pipelines controller to access its
metrics endpoint directly:

```bash
kubectl port-forward -n tekton-pipelines deployment/tekton-pipelines-controller 9097:9090 &
```

Wait for the port-forward to establish:

```bash
sleep 3
```

Now fetch the raw metrics:

```bash
curl -s http://localhost:9097/metrics | head -100
```

You will see a long list of Prometheus metrics. Let's look at the key Tekton
metrics specifically.

## Key Tekton metrics

Filter for Tekton-specific metrics:

```bash
curl -s http://localhost:9097/metrics | grep "^tekton_"
```

Here are the most important metrics:

| Metric | Description |
|--------|-------------|
| `tekton_pipelines_controller_running_pipelineruns_count` | Number of currently running PipelineRuns |
| `tekton_pipelines_controller_pipelinerun_duration_seconds` | Histogram of PipelineRun durations |
| `tekton_pipelines_controller_running_taskruns_count` | Number of currently running TaskRuns |
| `tekton_pipelines_controller_taskrun_duration_seconds` | Histogram of TaskRun durations |
| `tekton_pipelines_controller_pipelinerun_count` | Total count of PipelineRuns |
| `tekton_pipelines_controller_taskrun_count` | Total count of TaskRuns |

## Generate some metric data

To see meaningful metrics, let's create a Task and run it a few times:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: metrics-demo
spec:
  steps:
    - name: work
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Doing some work..."
        sleep 2
        echo "Done!"
EOF
```

Run it several times:

```bash
for i in 1 2 3; do
  tkn task start metrics-demo
  sleep 5
done
```

Wait for all runs to finish:

```bash
sleep 15
```

Now check the metrics again -- you should see non-zero counts:

```bash
curl -s http://localhost:9097/metrics | grep "tekton_pipelines_controller_taskrun_count"
```

```bash
curl -s http://localhost:9097/metrics | grep "tekton_pipelines_controller_taskrun_duration_seconds"
```

The controller is now reporting real data that Prometheus can scrape.
