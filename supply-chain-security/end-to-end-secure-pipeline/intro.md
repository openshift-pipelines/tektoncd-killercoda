# End-to-End Secure Pipeline: Clone, Build, Sign, Verify

In production, a secure CI/CD pipeline is not just about building code -- it is
about establishing an **unbroken chain of trust** from source code to deployed
artifact. This tutorial brings together Tekton Pipelines and Tekton Chains to
build a complete supply chain security workflow.

## The secure pipeline lifecycle

```
Source code --> Clone --> Build image --> Push to registry --> Chains signs --> Verify signature --> Deploy
```

At every stage, cryptographic signatures and attestations provide proof that:

- The **correct source code** was used (git commit tracking)
- The **correct build process** ran (SLSA provenance)
- The **artifact was not tampered with** after building (image signature)

## What you will learn

In this tutorial, you will:

- Configure Tekton Chains for **x509 signing** with **OCI storage** and
  **SLSA/v1 provenance**
- Generate **cosign key pairs** for image signing
- Build a multi-task Pipeline that **clones, builds, and pushes** a container
  image
- See Chains **automatically sign** the image and attach **SLSA provenance**
- Verify signatures and attestations as a **consumer** with only the public key

## Prerequisites

This tutorial assumes familiarity with:

- Tekton Tasks and Pipelines (see the Getting Started tutorials)
- Basic container image concepts (Dockerfile, registry)

While the environment loads, Tekton Pipelines, Tekton Chains, a local container
registry, `tkn`, and `cosign` are being installed. This may take a minute or two.
