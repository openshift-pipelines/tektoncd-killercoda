# Tekton + Cloud Native Buildpacks

**Cloud Native Buildpacks** (CNB) automatically detect your application's
language and framework, then build a production-ready container image -- all
without a Dockerfile. Combined with Tekton, you get a fully automated Pipeline
that builds from source to container image.

**Note:** Buildpacks are memory-intensive (approximately 2GB peak). This tutorial
may run slower than others on the single-node Killercoda environment.

In this tutorial, you will learn:

- How to set up the **Buildpacks Task** from the Tekton Catalog
- How to **build an app** into a container image without a Dockerfile
- How to create a **Pipeline** that clones, builds, and deploys with Buildpacks

**Prerequisites:** Familiarity with Tekton Tasks and Pipelines.

While the environment loads, Tekton Pipelines, a local registry, and the tkn CLI
are being installed. This may take a minute or two.
