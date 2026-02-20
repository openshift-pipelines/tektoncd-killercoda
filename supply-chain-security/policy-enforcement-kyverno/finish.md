# Congratulations!

You have implemented a complete supply chain security enforcement workflow using
Tekton Chains for signing and Kyverno for policy enforcement.

## What you learned

- How to install and configure **Kyverno** as a Kubernetes policy engine
- How to create a **ClusterPolicy** with `verifyImages` rules that require
  cosign signatures
- How **signed images** (built by Tekton + signed by Chains) pass policy
  verification
- How **unsigned images** (pushed directly) are blocked by Kyverno
- The complete **build-time signing + deploy-time enforcement** security model

## The defense-in-depth model

| Layer | Component | What it does |
|-------|-----------|-------------|
| Build | Tekton Pipelines | Builds container images |
| Sign | Tekton Chains | Automatically signs images with cosign |
| Attest | Tekton Chains | Attaches SLSA provenance attestation |
| Enforce | Kyverno | Blocks unsigned images at admission time |

## What is next

- [End-to-End Secure Pipeline](/supply-chain-security/end-to-end-secure-pipeline) --
  Build the full Pipeline with clone, build, sign, and verify
- [Kyverno Documentation](https://kyverno.io/docs/) -- Explore advanced
  Kyverno policies including attestation verification
- [Kyverno Image Verification](https://kyverno.io/docs/writing-policies/verify-images/) --
  Deep dive into Kyverno image verification features
- [Sigstore Policy Controller](https://docs.sigstore.dev/policy-controller/overview/) --
  An alternative to Kyverno for Sigstore-based image verification
