# Remote Resolvers -- Fetch Tasks Without Installing Them

In earlier versions of Tekton, **ClusterTask** was a cluster-scoped resource that
let you share Tasks across namespaces. ClusterTask was deprecated in Tekton
Pipelines v0.40 and **removed entirely in v1.0.0**. Remote Resolvers are the
modern replacement.

**Remote Resolvers** fetch Task and Pipeline definitions at runtime from external
sources -- without requiring you to `kubectl apply` them beforehand. When a
TaskRun or PipelineRun references a resolver, the Tekton Pipelines controller
fetches the definition on the fly, resolves it, and executes it.

Tekton ships with four built-in resolver types:

- **Hub Resolver** -- Fetches Tasks and Pipelines from Artifact Hub, the
  community catalog of reusable Tekton resources.
- **Git Resolver** -- Fetches definitions from any Git repository (public or
  private), specified by URL, revision, and file path.
- **Cluster Resolver** -- Fetches Tasks from another namespace in the same
  cluster, making it the direct replacement for ClusterTask.
- **Bundle Resolver** -- Fetches Tasks from OCI bundle images stored in
  container registries.

All four resolvers are built into the Tekton Pipelines controller. There is no
extra installation or configuration needed to use them.

In this tutorial, you will learn:

- How to use the **Hub Resolver** to fetch a community Task from Artifact Hub
- How to use the **Git Resolver** to fetch a Task from a Git repository
- How to use the **Cluster Resolver** to share Tasks across namespaces
- How to **compare** resolver types and mix them in a single Pipeline

**Prerequisites:** You should be familiar with creating Tasks, TaskRuns, and
Pipelines (covered in the Basic Pipeline tutorial).

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
