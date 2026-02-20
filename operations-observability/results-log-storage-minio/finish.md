# Congratulations!

You have successfully configured Tekton Results to store pipeline logs in
MinIO, an S3-compatible object store.

In this tutorial, you learned:

- **The problem** -- pod deletion causes permanent log loss, making it
  impossible to debug past pipeline runs
- **S3 log storage** -- how to configure Results to capture step logs and
  store them in MinIO using S3-compatible storage
- **Persistence proof** -- running Pipelines, deleting pods, and still
  retrieving logs through the Results API
- **Production value** -- aggressive pruning plus persistent log storage
  keeps your cluster healthy while preserving full history

## Next steps

- [Tekton Results documentation](https://tekton.dev/docs/results/) -- full
  reference for the Results API and configuration options
- [MinIO documentation](https://min.io/docs/) -- production MinIO deployment
  with persistence, replication, and encryption
- [AWS S3 backend](https://tekton.dev/docs/results/) -- replace MinIO with
  AWS S3 for cloud-native production deployments
- [Results log retention](https://tekton.dev/docs/results/) -- configure
  lifecycle policies to manage log storage growth
