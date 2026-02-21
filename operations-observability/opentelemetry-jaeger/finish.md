# Congratulations!

You have learned how to use **OpenTelemetry and Jaeger** for distributed tracing
of Tekton Pipeline runs.

## What you learned

- Deploying **Jaeger all-in-one** as a tracing backend
- Configuring Tekton to **export traces** via the config-tracing ConfigMap
- Understanding the **span hierarchy**: PipelineRun -> TaskRun -> Step
- Using Jaeger to **analyze performance** and identify bottlenecks

## Key points to remember

- Enable tracing via `config-tracing` ConfigMap with Jaeger endpoint
- Each PipelineRun, TaskRun, and step becomes a trace span
- Parallel Tasks show as overlapping spans in the timeline
- Use trace comparison to detect performance regressions
- Jaeger all-in-one is for development; use Jaeger Operator for production

## Real-world use cases

- **Performance optimization**: Find the slowest steps in your CI/CD Pipeline
- **Debugging failures**: See exactly where and when failures occurred
- **Capacity planning**: Understand scheduling overhead and parallelism
- **SLA monitoring**: Track Pipeline execution time against SLAs

## What's next

- [Prometheus + Grafana](https://killercoda.com/tekton/course/operations-observability/prometheus-grafana) - Metrics-based monitoring
- [Feature Flags](https://killercoda.com/tekton/course/operations-observability/feature-flags-tektonconfig) - Configure Tekton behavior
- [OpenTelemetry documentation](https://opentelemetry.io/docs/) - Full OpenTelemetry reference
