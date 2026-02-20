# SLSA Provenance Deep Dive

[SLSA](https://slsa.dev/) (Supply-chain Levels for Software Artifacts) is a
security framework for ensuring the integrity of software artifacts throughout
the supply chain. A key part of SLSA is **provenance** - a record of how an
artifact was built, including what inputs were used and what build process was
followed.

Tekton Chains automatically generates SLSA provenance for every TaskRun in your
cluster. In this tutorial, you will go beyond the basics and take a deep dive
into the provenance attestation format.

You will learn:

- How to configure Chains to generate **SLSA v1 provenance**
- How to extract and decode the provenance attestation from TaskRun annotations
- How to walk through the SLSA provenance fields: `buildType`, `invocation`,
  `buildConfig`, and `materials`
- What SLSA levels (L1 through L4) mean and what Tekton Chains provides
- How to verify provenance attestations with `cosign`

While the environment loads, Tekton Pipelines, Tekton Chains, the `tkn` CLI,
and `cosign` are being installed in the background. This may take a few minutes.
