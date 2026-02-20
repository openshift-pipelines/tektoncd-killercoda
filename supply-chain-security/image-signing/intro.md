# Build, Sign, and Verify Container Images with Chains

Beyond signing TaskRun metadata, Tekton Chains can automatically sign **OCI
container images** that your pipelines produce. This is the supply chain
security workflow that production CI/CD pipelines need.

## Why sign container images?

When you deploy a container image, how do you know it came from your CI/CD
system and was not tampered with? Image signing provides:

- **Authenticity** - proof that your build system produced the image
- **Integrity** - proof that the image was not modified after building
- **Provenance** - metadata about what source code and build process created it

## What you will learn

In this tutorial, you will:

- Set up **cosign signing keys** for image signing
- Create a Task that **builds and pushes** a container image to a local registry
- See Chains **automatically sign the image** in the registry
- **Verify the signature** with `cosign verify`
- **Inspect the SLSA attestation** attached to the image

## The build-sign-verify lifecycle

```
Build image --> Push to registry --> Chains signs it --> Verify before deploy
```

This is the production pattern: images are signed at build time and verified
at deploy time, creating an unbroken chain of trust from source to deployment.

While the environment loads, Tekton Pipelines, Tekton Chains, a local container
registry, `tkn`, and `cosign` are being installed. This may take a minute or two.
