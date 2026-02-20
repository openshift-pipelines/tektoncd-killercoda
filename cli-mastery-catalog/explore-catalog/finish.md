# Congratulations!

You have learned how to discover, install, and use community Tasks from the
Tekton Catalog!

## What you learned

- How to find Tekton Tasks on **Artifact Hub** (the current home of the Tekton
  Catalog)
- How to install catalog Tasks like **git-clone** and **kaniko** directly from
  the Tekton Catalog GitHub repository
- How catalog Tasks follow **conventions** for parameters, workspaces, and
  results that make them composable
- How to chain catalog Tasks in a **Pipeline** with shared workspaces
- How to use the **Hub Resolver** to fetch Tasks at runtime without
  pre-installing them

## Pre-install vs Resolver: when to use each

| Approach | Best for |
|----------|----------|
| `kubectl apply` (pre-install) | Air-gapped clusters, offline environments |
| Hub Resolver | Most production workloads, version pinning per Pipeline |
| Git Resolver | Private catalog repositories, custom Tasks |

## What is next

- [Remote Resolvers Deep Dive](/cli-mastery-catalog/remote-resolvers) - Learn
  about Git, Cluster, and Bundle resolvers in addition to Hub
- [Tekton Bundles](/cli-mastery-catalog/tekton-bundles) - Package your own
  Tasks as OCI artifacts
- [Tekton Catalog on GitHub](https://github.com/tektoncd/catalog) - Browse the
  full catalog of community Tasks
- [Artifact Hub Tekton Tasks](https://artifacthub.io/packages/search?kind=13) -
  Search for Tasks on Artifact Hub
