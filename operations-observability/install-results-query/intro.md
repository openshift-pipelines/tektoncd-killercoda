# Install Tekton Results and Query Pipeline History

When you run Tekton Pipelines, each PipelineRun and TaskRun is stored as a
Kubernetes custom resource in **etcd**. This works fine at first, but etcd was
not designed for long-term storage of high-volume data. Over time, old runs
are pruned to keep the cluster healthy -- and with them, you lose your
pipeline history.

**Tekton Results** solves this problem. It is an add-on component that watches
for completed PipelineRuns and TaskRuns, captures their data, and stores it
in an external database (PostgreSQL). This gives you:

- **Long-term storage** -- pipeline history survives pruning and cluster
  restarts
- **A REST API** -- query, filter, and paginate through historical runs
- **Kubernetes CRD integration** -- browse results with `kubectl`

In this tutorial, you will learn:

- What Tekton Results provides and how it fits into the architecture
- How Results automatically captures PipelineRun data
- How to query the Results REST API for historical pipeline data
- How to use `kubectl` to browse Result resources

While the environment loads, Tekton Pipelines v1.9.0, Tekton Results v0.18.0,
PostgreSQL, TLS certificates, and the `tkn` CLI are being installed in the
background. This may take a few minutes.
