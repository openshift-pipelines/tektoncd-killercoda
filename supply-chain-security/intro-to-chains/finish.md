# Congratulations!

You have learned how to use Tekton Chains for automatic TaskRun signing!

## What you learned

- How to generate a **cosign key pair** stored as a Kubernetes Secret
- How to configure Chains for **SLSA v1 provenance** format
- How Chains **automatically signs** every completed TaskRun
- How to **verify signatures** using cosign and the public key
- How to **inspect SLSA provenance** attestations

## The Chains signing flow

1. A TaskRun completes in your cluster
2. The Chains controller detects the completion
3. Chains generates an SLSA provenance document
4. Chains signs the provenance with your private key
5. The signature is stored as a TaskRun annotation
6. Anyone with the public key can verify the signature

## What is next

- [Build, Sign, and Verify Container Images](../image-signing/) -- Learn how
  Chains signs OCI container images, not just TaskRuns
- [SLSA Provenance Deep Dive](https://slsa.dev/) -- Understand SLSA levels
  and provenance requirements
- [Tekton Chains documentation](https://tekton.dev/docs/chains/) -- Full
  reference for Chains configuration
- [Sigstore documentation](https://docs.sigstore.dev/) -- The broader
  ecosystem for software supply chain security
