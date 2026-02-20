# Retries, Timeouts, and Error Handling

Real-world CI/CD pipelines must deal with failure. Network calls time out,
flaky tests fail intermittently, and external services go down. Tekton provides
built-in mechanisms to handle these situations gracefully:

- **Retries** - automatically re-run a Task when it fails
- **Timeouts** - set time limits at the Task and Pipeline level
- **Finally Tasks** - run cleanup or notification Tasks regardless of Pipeline outcome

In this tutorial, you will learn:

- How to configure **retries** on a PipelineTask to handle flaky failures
- How to set **timeouts** at the PipelineTask and PipelineRun level
- How to combine retries, timeouts, and **finally** Tasks into a robust Pipeline

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
