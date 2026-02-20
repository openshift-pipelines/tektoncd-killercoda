# Create a Grafana dashboard

Now let's connect Grafana to Prometheus and create a dashboard to visualize
Tekton pipeline metrics.

## Access Grafana

Port-forward the Grafana service:

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80 &
```

```bash
sleep 3
```

In a production environment, you would open your browser to
`http://localhost:3000`. In this Killercoda environment, you can access
Grafana through the exposed port.

The default credentials are:
- **Username:** admin
- **Password:** admin

## Add Prometheus as a data source

We can use the Grafana API to configure the data source programmatically:

```bash
curl -s -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus-server.monitoring.svc.cluster.local:80",
    "access": "proxy",
    "isDefault": true
  }' | python3 -m json.tool
```

Verify the data source was created:

```bash
curl -s http://admin:admin@localhost:3000/api/datasources | python3 -m json.tool
```

## Create a Tekton dashboard

Now let's create a dashboard with panels for key Tekton metrics:

```bash
cat <<'DASHBOARD_EOF' > /tmp/tekton-dashboard.json
{
  "dashboard": {
    "title": "Tekton Pipelines Overview",
    "tags": ["tekton", "ci-cd"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Running PipelineRuns",
        "type": "stat",
        "gridPos": {"h": 6, "w": 6, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "tekton_pipelines_controller_running_pipelineruns_count",
            "legendFormat": "Running PipelineRuns"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 5},
                {"color": "red", "value": 10}
              ]
            }
          }
        }
      },
      {
        "title": "Running TaskRuns",
        "type": "stat",
        "gridPos": {"h": 6, "w": 6, "x": 6, "y": 0},
        "targets": [
          {
            "expr": "tekton_pipelines_controller_running_taskruns_count",
            "legendFormat": "Running TaskRuns"
          }
        ]
      },
      {
        "title": "PipelineRun Duration (avg over 5m)",
        "type": "timeseries",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 6},
        "targets": [
          {
            "expr": "rate(tekton_pipelines_controller_pipelinerun_duration_seconds_sum[5m]) / rate(tekton_pipelines_controller_pipelinerun_duration_seconds_count[5m])",
            "legendFormat": "Avg Duration (s)"
          }
        ]
      },
      {
        "title": "Total PipelineRuns",
        "type": "stat",
        "gridPos": {"h": 6, "w": 6, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "tekton_pipelines_controller_pipelinerun_count",
            "legendFormat": "Total"
          }
        ]
      },
      {
        "title": "Total TaskRuns",
        "type": "stat",
        "gridPos": {"h": 6, "w": 6, "x": 18, "y": 0},
        "targets": [
          {
            "expr": "tekton_pipelines_controller_taskrun_count",
            "legendFormat": "Total"
          }
        ]
      }
    ],
    "schemaVersion": 38,
    "version": 0
  },
  "overwrite": true
}
DASHBOARD_EOF
```

Push the dashboard to Grafana:

```bash
curl -s -X POST http://admin:admin@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @/tmp/tekton-dashboard.json | python3 -m json.tool
```

## Verify the dashboard was created

```bash
curl -s http://admin:admin@localhost:3000/api/search?query=Tekton | python3 -m json.tool
```

You should see the "Tekton Pipelines Overview" dashboard in the results.

## Test the dashboard with live data

Run a few more PipelineRuns to see the dashboard metrics update:

```bash
for i in 1 2 3; do
  cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: metrics-pipeline-run-
spec:
  pipelineRef:
    name: metrics-pipeline
EOF
  sleep 2
done
```

After these runs complete, the Grafana dashboard will show:
- **Running PipelineRuns** -- the current count of active runs
- **Running TaskRuns** -- the current count of active TaskRuns
- **PipelineRun Duration** -- a time-series graph showing average duration
- **Total PipelineRuns/TaskRuns** -- cumulative counts

In a real production environment, you would access the Grafana UI in your
browser and see these panels updating in real time.
