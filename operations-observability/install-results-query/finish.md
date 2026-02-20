# Congratulations!

You have successfully installed Tekton Results and learned how to query
pipeline execution history!

In this tutorial, you learned:

- **Why Results matters** -- etcd is not designed for long-term pipeline
  history, and pruning causes data loss
- **How Results works** -- the watcher automatically captures completed
  PipelineRuns and TaskRuns into PostgreSQL
- **How to query the REST API** -- using curl to list results, records, and
  apply filters
- **How to use kubectl** -- browsing Results and Records as Kubernetes
  custom resources

## Next steps

- [Tekton Results documentation](https://tekton.dev/docs/results/) -- full
  reference for the Results API
- [Configure Results for production](https://tekton.dev/docs/results/install/) --
  use a managed PostgreSQL instance and proper TLS certificates
- [Automatic Pruning](https://tekton.dev/docs/operator/tektonconfig/) --
  configure pruning with confidence, knowing Results preserves your history
- [Tekton Dashboard](https://tekton.dev/docs/dashboard/) -- the Dashboard
  can use Results as a backend for displaying historical runs
