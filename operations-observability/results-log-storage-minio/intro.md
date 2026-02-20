# Results Log Storage with MinIO

When Tekton runs a Pipeline, each step's output is captured as container logs in
the pod. Once the pod is deleted -- whether through garbage collection, pruning,
or manual cleanup -- those logs are gone forever. In production environments
where you run hundreds of pipelines daily, this is a real problem. You cannot
debug a failed build from last week if the pod no longer exists.

**Tekton Results** can solve this. Beyond storing PipelineRun and TaskRun
metadata in PostgreSQL, Results can also capture and store **step logs** in an
S3-compatible object store. This means:

- **Logs survive pod deletion** -- even after aggressive pruning, every step's
  output is preserved
- **S3-compatible storage** -- use MinIO, AWS S3, Google Cloud Storage, or any
  S3-compatible backend
- **API access** -- retrieve logs programmatically through the Results API

In this tutorial, you will learn:

- How to configure Tekton Results to store logs in MinIO (an S3-compatible
  object store)
- How to run Pipelines, delete the pods, and still retrieve the logs
- How to browse stored logs via the Results API and MinIO directly

While the environment loads, Tekton Pipelines v1.9.0, Tekton Results v0.18.0,
MinIO, and the `tkn` CLI are being installed in the background. This may take a
few minutes.
