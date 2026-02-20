# Congratulations!

You have learned how to build, sign, and verify container images with Tekton
Chains!

## What you learned

- How to set up **cosign signing keys** for image signing
- How to create a Task with **IMAGE_URL and IMAGE_DIGEST results** that Chains
  detects
- How Chains **automatically signs container images** in the registry
- How to **verify image signatures** with `cosign verify`
- How to **inspect SLSA provenance attestations** attached to images

## The build-sign-verify lifecycle

1. A Tekton Task builds and pushes a container image
2. The Task emits `IMAGE_URL` and `IMAGE_DIGEST` results
3. Chains detects these results and signs the image
4. The signature and attestation are pushed to the registry
5. At deploy time, `cosign verify` confirms authenticity

## What is next

- [SLSA Provenance Deep Dive](https://slsa.dev/) - Understand SLSA levels and
  provenance requirements
- [Tekton Chains documentation](https://tekton.dev/docs/chains/) - Full
  reference for Chains configuration and signing backends
- [Sigstore Keyless Signing](https://docs.sigstore.dev/cosign/keyless/) - Sign
  without managing keys using OIDC identity
- [Kyverno Image Verification](https://kyverno.io/docs/writing-policies/verify-images/) -
  Enforce image signatures at deploy time with policy
