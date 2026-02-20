# Congratulations!

You have successfully configured automatic pruning for Tekton PipelineRuns and
TaskRuns using the Tekton Operator.

In this tutorial, you learned:

- How accumulated PipelineRuns and TaskRuns create **storage and performance
  problems** in production clusters
- How to configure the **pruner** in TektonConfig with schedule, resource types,
  and retention count
- How the Operator **manages the pruner CronJob** automatically
- **Production recommendations** for pruning schedules and retention policies

Automatic pruning is a critical operational practice for any production Tekton
installation. Combined with Tekton Results for long-term archival, it ensures
your cluster stays healthy while retaining the pipeline history you need.

To learn more, explore these resources:

- [Tekton Operator documentation](https://tekton.dev/docs/operator/) - Full Operator reference
- [Tekton Results](https://tekton.dev/docs/results/) - Archive run data for long-term storage
- [Tekton documentation](https://tekton.dev/docs/) - Full documentation for all Tekton components
