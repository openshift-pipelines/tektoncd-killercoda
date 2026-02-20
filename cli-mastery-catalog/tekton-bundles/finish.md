# Congratulations!

You have successfully learned how to package, distribute, and use Tekton
Bundles!

In this tutorial, you learned:

- **What Bundles are** -- OCI artifacts that package Tekton Tasks and
  Pipelines for distribution
- **How to push bundles** -- using `tkn bundle push` to package YAML files
  and push them to a registry
- **How to use bundles** -- referencing bundled Tasks in PipelineRuns via
  the Bundle resolver with `resolver: bundles`
- **Versioning** -- using OCI tags (v1, v2) to version your Tasks
- **Multi-resource bundles** -- packaging multiple Tasks into a single
  bundle

## Next steps

- [Tekton Bundles documentation](https://tekton.dev/docs/pipelines/tekton-bundle-contracts/) --
  full reference for the bundle format
- [Remote Resolvers](https://tekton.dev/docs/pipelines/bundle-resolver/) --
  learn about other resolvers (Hub, Git, Cluster)
- [Artifact Hub](https://artifacthub.io/packages/search?kind=10) -- browse
  community-contributed Tekton Tasks
- Push bundles to public registries like Docker Hub or GitHub Container
  Registry to share Tasks across organizations
