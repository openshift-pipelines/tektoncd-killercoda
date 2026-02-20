# Explore the Tekton Catalog on Artifact Hub

The Tekton community maintains a **catalog** of reusable Tasks and Pipelines
that solve common CI/CD problems. Instead of writing everything from scratch,
you can install battle-tested Tasks for cloning Git repositories, building
container images, running tests, and much more.

## Why use catalog Tasks?

- **Save time** - skip writing boilerplate for common operations
- **Community tested** - Tasks are reviewed and maintained by the community
- **Standardized** - catalog Tasks follow Tekton conventions for parameters,
  workspaces, and results
- **Composable** - chain catalog Tasks together in Pipelines

## Where to find them

The Tekton Catalog is hosted on **Artifact Hub** at
[artifacthub.io](https://artifacthub.io/packages/search?kind=13). The old
`hub.tekton.dev` site has been retired. All catalog discovery now happens
through Artifact Hub.

## What you will learn

In this tutorial, you will:

- Install a catalog Task (**git-clone**) directly from the Tekton Catalog GitHub
  repository
- Inspect the Task and understand how catalog Tasks follow conventions
- Combine **git-clone** and **kaniko** catalog Tasks into a Pipeline
- Use **Remote Resolvers** to fetch Tasks at runtime without pre-installing them

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed. This may take a minute or two.
