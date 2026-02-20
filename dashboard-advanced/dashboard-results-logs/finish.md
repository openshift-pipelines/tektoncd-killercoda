# Congratulations!

You have successfully configured the Tekton Dashboard to use Tekton Results
as an external logs backend for persistent log viewing.

In this tutorial, you learned:

- **External logs configuration** - how to add the `--external-logs` flag to
  the Dashboard deployment pointing to the Results API
- **Seamless fallback** - the Dashboard automatically queries Results when
  pod logs are unavailable
- **Survive pruning** - deleted PipelineRuns and their logs remain accessible
  through the Dashboard via Results
- **The best of both worlds** - aggressive pruning for cluster health plus
  full history in the Dashboard

## The production pattern

The recommended production setup is:

1. Install Tekton Results with a managed PostgreSQL database
2. Configure the Dashboard with `--external-logs` pointing to Results
3. Set up automatic pruning with short TTLs (hours or days)
4. Let Results handle long-term storage (weeks or months)

This gives you a clean cluster with low etcd usage while maintaining complete
pipeline history and logs accessible through the Dashboard UI.

## Next steps

- [Tekton Dashboard documentation](https://tekton.dev/docs/dashboard/) --
  full reference for Dashboard configuration
- [Tekton Results documentation](https://tekton.dev/docs/results/) --
  full reference for Results installation and API
- [Automatic pruning](https://tekton.dev/docs/operator/tektonconfig/) --
  configure pruning schedules with confidence
- [Results with S3 log storage](https://tekton.dev/docs/results/) - store
  logs in S3-compatible storage for additional durability
