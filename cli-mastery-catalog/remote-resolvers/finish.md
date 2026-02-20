# Congratulations!

You have learned how to use **Remote Resolvers** in Tekton to fetch Task and
Pipeline definitions at runtime without pre-installing them.

## What you learned

- **Hub Resolver** -- Fetch community Tasks from Artifact Hub by name and
  version, without installing them locally
- **Git Resolver** -- Fetch Tasks from any Git repository using a URL, revision,
  and file path
- **Cluster Resolver** -- Share Tasks across namespaces by referencing them from
  a shared namespace, replacing the removed ClusterTask
- **Mixing resolvers** -- Combine different resolver types within a single
  Pipeline for maximum flexibility

## Key points to remember

- Remote Resolvers **replace ClusterTask**, which was removed in Tekton
  Pipelines v1.0.0
- All four resolvers (Hub, Git, Cluster, Bundle) are **built into the Tekton
  Pipelines controller** -- no extra installation needed
- You can **mix resolver types** within a single Pipeline, using different
  resolvers for different tasks
- **Hub Resolver** for community catalog tasks, **Git Resolver** for private or
  internal tasks, **Cluster Resolver** for shared in-cluster tasks, **Bundle
  Resolver** for versioned OCI-packaged tasks
- Always **pin versions** (Hub version, Git revision, Bundle digest) in
  production for reproducible builds

## What's next

- [Tekton Resolvers documentation](https://tekton.dev/docs/pipelines/resolution/) -- Full reference for all resolver types
- [Hub Resolver configuration](https://tekton.dev/docs/pipelines/hub-resolver/) -- Advanced Hub Resolver options
- [Git Resolver configuration](https://tekton.dev/docs/pipelines/git-resolver/) -- Private repo authentication and advanced options
- [Cluster Resolver configuration](https://tekton.dev/docs/pipelines/cluster-resolver/) -- RBAC and namespace configuration
- [Bundle Resolver configuration](https://tekton.dev/docs/pipelines/bundle-resolver/) -- OCI bundle creation and usage
