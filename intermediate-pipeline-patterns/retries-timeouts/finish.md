# Congratulations!

You have learned how to build resilient Tekton Pipelines using retries,
timeouts, and finally Tasks.

## What you learned

- **Retries** -- how to configure `retries` on a PipelineTask so that flaky
  Tasks are automatically re-run
- **Task-level timeouts** -- how to set `timeout` on a PipelineTask to prevent
  Tasks from hanging indefinitely
- **Pipeline-level timeouts** -- how to use `spec.timeouts.pipeline`,
  `spec.timeouts.tasks`, and `spec.timeouts.finally` on a PipelineRun
- **Finally Tasks** -- how to use `$(tasks.status)` to report Pipeline outcomes
  regardless of success or failure
- **Combining all three** -- how to build production-grade Pipelines that
  handle errors gracefully

## Next steps

- [When Expressions](https://tekton.dev/docs/pipelines/pipelines/#guard-task-execution-using-when-expressions) -- Conditionally skip Tasks
- [Finally Tasks](https://tekton.dev/docs/pipelines/pipelines/#adding-finally-to-the-pipeline) -- More advanced finally patterns
- [Tekton documentation](https://tekton.dev/docs/) -- Full documentation for all Tekton components
