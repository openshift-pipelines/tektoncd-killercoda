# Introduction to Tekton Chains

[Tekton Chains](https://tekton.dev/docs/chains/) is an automatic signing
controller for Tekton. It watches for completed TaskRuns and PipelineRuns,
signs them, and stores the signatures and attestations.

## Why supply chain security matters

Software supply chain attacks are on the rise. Attackers target the build
process itself - injecting malicious code during CI/CD. To defend against
this, you need **provenance**: cryptographic proof of what was built, by whom,
and how.

Tekton Chains provides this automatically:

- **Signs every TaskRun** with a cryptographic key
- **Generates SLSA provenance** attestations
- **Integrates with Sigstore** (cosign, Rekor) for verification

## What you will learn

In this tutorial, you will:

- Generate a **cosign key pair** for signing
- Configure Chains to use **x509 signing** with SLSA provenance format
- Run a TaskRun and see Chains **automatically sign** it
- **Verify the signature** and inspect the SLSA provenance payload

## Part of the Sigstore ecosystem

Tekton Chains uses [cosign](https://docs.sigstore.dev/cosign/overview/) from
the Sigstore project for key management and signing. The signatures it produces
are standard and can be verified by anyone with the public key.

While the environment loads, Tekton Pipelines, Tekton Chains, `tkn`, and
`cosign` are being installed in the background. This may take a minute or two.
