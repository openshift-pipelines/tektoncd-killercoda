# Congratulations!

You have learned how to configure **Tekton Results retention policies** for
managing data lifecycle in production.

## What you learned

- Default Results behavior **keeps all records indefinitely**
- **Time-based retention**: Delete records older than a specified duration
- **Count-based retention**: Keep only the N most recent records per parent
- How the **retention worker** periodically cleans up expired records

## Key points to remember

- Configure via environment variables or ConfigMap on the Results deployment
- `retention-period` accepts Go duration format: 1h, 24h, 720h (30 days)
- `retention-limit` sets the maximum number of records per parent
- Both can be combined for a defense-in-depth approach
- Retention only affects the Results database, not Kubernetes resources
- Use Tekton Pruner for cleaning up Kubernetes PipelineRun/TaskRun objects

## Real-world use cases

- **Compliance**: Keep records for 90 days to meet audit requirements
- **Cost management**: Limit database growth for cloud-hosted PostgreSQL
- **Performance**: Prevent query slowdowns from large result sets
- **Tiered retention**: Short retention for dev, long retention for production

## What's next

- [Results Log Storage with MinIO](https://killercoda.com/tekton/course/operations-observability/results-log-storage-minio) - S3-compatible log persistence
- [Automatic Pruning](https://killercoda.com/tekton/course/operations-observability/automatic-pruning) - Clean up Kubernetes resources
- [Results documentation](https://tekton.dev/docs/results/) - Full reference
