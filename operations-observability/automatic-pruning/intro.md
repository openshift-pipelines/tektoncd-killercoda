# Automatic Pruning of Pipeline and TaskRuns

In production Kubernetes clusters running Tekton, PipelineRuns and TaskRuns
accumulate over time. Each run is stored as a Kubernetes custom resource in
etcd, the cluster's backing store. Over weeks and months, this can lead to:

- **Storage pressure** - etcd has limited storage, and thousands of run objects
  consume significant space
- **Performance degradation** - Listing and querying runs becomes slower as the
  number grows
- **Operational noise** - Old completed runs clutter the output of `tkn` and
  Dashboard views

The Tekton Operator provides a built-in **pruner** that automatically cleans up
old PipelineRuns and TaskRuns on a configurable schedule. This is managed
entirely through the TektonConfig resource - no CronJobs or external tools
required.

In this tutorial, you will learn:

- How accumulated runs create **storage and performance problems**
- How to configure the **pruner** in TektonConfig
- How to verify that pruning is working and tune it for production

While the environment loads, the Tekton Operator is being installed and sample
TaskRuns are being generated in the background. This may take a few minutes.
