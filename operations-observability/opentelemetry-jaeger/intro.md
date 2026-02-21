# Tekton + OpenTelemetry + Jaeger: Distributed Tracing

When Pipelines have many Tasks running in parallel and series, understanding
**where time is spent** becomes critical. Distributed tracing with
**OpenTelemetry** and **Jaeger** gives you a visual timeline of every TaskRun
and step, showing exactly how your Pipeline executes.

Tekton Pipelines can export **traces** via OpenTelemetry. Each PipelineRun,
TaskRun, and step becomes a **span** in a trace, letting you:

- See parallel vs sequential execution visually
- Identify slow steps and bottlenecks
- Measure scheduling overhead (time between Tasks)
- Compare runs to detect performance regressions

In this tutorial, you will learn:

- How to deploy **Jaeger all-in-one** as a tracing backend
- How to configure Tekton to **export traces** via OpenTelemetry
- How to **view and analyze** Pipeline traces in the Jaeger UI

**Prerequisites:** Familiarity with Tasks, Pipelines, and PipelineRuns.

While the environment loads, Tekton Pipelines, Jaeger, and the tkn CLI are being
installed. This may take a minute or two.
