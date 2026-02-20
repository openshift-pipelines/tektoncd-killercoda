# Congratulations!

You have learned how to use Tekton's **Pipelines in Pipelines** feature to
compose modular, reusable CI/CD workflows.

## What you learned

- Creating a **child Pipeline** that works as a self-contained building block
- Using **`pipelineRef`** in a PipelineTask to reference another Pipeline
- **Passing parameters** from parent to child Pipeline
- **Reading child Pipeline results** in the parent using standard result syntax

## Key points to remember

- PiP requires `enable-api-fields: beta` (or `alpha`) in feature-flags ConfigMap
- Use `pipelineRef` instead of `taskRef` in a PipelineTask to reference a Pipeline
- Child Pipeline results are accessed like Task results: `$(tasks.<name>.results.<result>)`
- Each child execution creates its own PipelineRun with independent status
- Child Pipelines are regular Pipelines -- they can also be run standalone

## Real-world use cases

- **Reusable build Pipelines**: Different release Pipelines share the same build sub-Pipeline
- **Team-owned components**: Each team maintains their own Pipeline, a parent orchestrates them
- **Testing tiers**: Separate Pipelines for unit tests, integration tests, and E2E tests
- **Multi-service deployments**: Compose per-service Pipelines into a unified release

## What's next

- [Object and Array Parameters](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/object-array-params) - Structured parameter types
- [Matrix](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/matrix-fan-out) - Fan out Tasks across parameter combinations
- [PiP documentation](https://tekton.dev/docs/pipelines/pipelines/#using-other-pipelines) - Full reference
