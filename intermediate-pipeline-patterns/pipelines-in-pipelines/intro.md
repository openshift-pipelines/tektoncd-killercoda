# Pipelines in Pipelines: Nested Composition

As your CI/CD grows, you will want to **compose Pipelines from other Pipelines**
rather than cramming everything into a single monolithic definition. Tekton's
**Pipelines in Pipelines** (PiP) feature lets a PipelineTask reference another
Pipeline instead of a Task, creating a nested execution hierarchy.

This is a **beta feature** that enables:

- **Reuse**: Define a build Pipeline once and reference it from multiple parent
  Pipelines
- **Modularity**: Teams own their sub-Pipelines independently
- **Composition**: Build complex workflows from simpler, tested building blocks
- **Scoping**: Child PipelineRuns have their own parameters, results, and
  workspaces

In this tutorial, you will learn:

- How to create a **child Pipeline** that will be used as a building block
- How to use **`pipelineRef`** in a PipelineTask to reference another Pipeline
- How to **pass parameters and results** between parent and child Pipelines

**Prerequisites:** Familiarity with Tasks, Pipelines, and PipelineRuns.

**Note:** This feature requires `enable-api-fields: beta` (or `alpha`) in the
Tekton Pipelines feature-flags ConfigMap. The install script enables this
automatically.

While the environment loads, Tekton Pipelines is being installed with beta API
fields enabled. This may take a minute or two.
