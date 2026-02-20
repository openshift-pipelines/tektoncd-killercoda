# Tekton + Prometheus + Grafana: Observability Dashboard

Running CI/CD pipelines in production requires **observability** -- you need
to know how many pipelines are running, how long they take, and whether they
are succeeding or failing. Tekton Pipelines has built-in support for
Prometheus metrics, making it straightforward to build monitoring dashboards.

In this tutorial, you will learn:

- What metrics the Tekton Pipelines controller exposes out of the box
- How to query those metrics in Prometheus using PromQL
- How to create a Grafana dashboard to visualize pipeline performance

The architecture is simple:

1. **Tekton controller** exposes metrics at `:9090/metrics`
2. **Prometheus** scrapes those metrics and stores them as time-series data
3. **Grafana** connects to Prometheus and renders dashboards

While the environment loads, Tekton Pipelines v1.9.0, the `tkn` CLI,
Prometheus, and Grafana are being installed in the background. This may take
a few minutes.
