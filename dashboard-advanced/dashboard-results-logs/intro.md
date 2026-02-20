# Dashboard with Results: Persistent Logs

The Tekton Dashboard displays pipeline logs by reading container logs from the
pods that executed each step. This works perfectly - until the pods are
deleted. Once pods are gone (through pruning, garbage collection, or manual
cleanup), the Dashboard shows empty logs. For developers trying to debug a
failed build from yesterday, this is frustrating.

**Tekton Results** solves this by capturing and storing logs externally. When
you configure the Dashboard to use Results as an **external logs** backend,
the Dashboard seamlessly falls back to Results when pod logs are unavailable.
From the user's perspective, logs are always there - whether the pod exists
or not.

This is the "aha moment": you can **prune aggressively** for etcd health
while keeping full pipeline history and logs available in the Dashboard.

In this tutorial, you will learn:

- How to install the Dashboard with the `--external-logs` flag pointing to
  the Results API
- How logs appear in the Dashboard before and after pod deletion
- How to configure log retention so pruned PipelineRuns still have full logs

While the environment loads, Tekton Pipelines v1.9.0, Tekton Results v0.18.0,
the Tekton Dashboard, and the `tkn` CLI are being installed in the background.
This may take a few minutes.
