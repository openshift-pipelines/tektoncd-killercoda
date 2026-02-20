# Congratulations!

You have successfully set up a complete observability stack for Tekton
Pipelines with Prometheus and Grafana!

In this tutorial, you learned:

- **Tekton's built-in metrics** - the controller exposes Prometheus metrics
  at `:9090/metrics` without any extra configuration
- **Key metrics** - `running_pipelineruns_count`, `pipelinerun_duration_seconds`,
  `running_taskruns_count`, and total run counts
- **PromQL queries** - how to query Tekton metrics in Prometheus for
  operational insights
- **Grafana dashboards** - how to create dashboard panels that visualize
  pipeline performance in real time

## Next steps

- [Tekton observability docs](https://tekton.dev/docs/pipelines/metrics/) -
  full list of available metrics
- [Grafana alerting](https://grafana.com/docs/grafana/latest/alerting/) -
  set up alerts when pipelines fail or duration exceeds thresholds
- [Tekton Dashboard](https://tekton.dev/docs/dashboard/) - the built-in
  web UI for browsing pipeline runs
- [Tekton Results](https://tekton.dev/docs/results/) - add long-term
  storage for pipeline history
