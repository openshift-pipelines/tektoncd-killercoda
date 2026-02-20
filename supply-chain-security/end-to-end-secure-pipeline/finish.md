# Congratulations!

You have built a complete end-to-end secure pipeline with Tekton Chains,
covering the full supply chain security lifecycle from source code to verified
deployment.

## What you learned

- How to configure Tekton Chains for **x509 signing**, **OCI storage**, and
  **SLSA/v1 provenance**
- How to create a multi-task Pipeline that **clones, builds, and pushes** a
  container image
- How the **IMAGE_URL and IMAGE_DIGEST** result convention tells Chains which
  images to sign
- How Chains **automatically signs images** and attaches **SLSA provenance
  attestations**
- How to **verify signatures** and **inspect attestations** as a consumer with
  only the public key
- Why verification with the **wrong key fails**, proving tamper detection works

## The complete supply chain security lifecycle

```
1. Developer pushes code
2. Tekton Pipeline clones and builds an image
3. Task emits IMAGE_URL + IMAGE_DIGEST results
4. Chains detects these results and signs the image
5. Chains attaches SLSA provenance attestation
6. Consumer verifies signature with public key
7. Consumer inspects provenance for build details
8. Deployment proceeds only if verification passes
```

## What is next

- [Policy Enforcement with Kyverno](/supply-chain-security/policy-enforcement-kyverno) --
  Automatically block unsigned images at deploy time
- [SLSA Provenance Deep Dive](/supply-chain-security/slsa-provenance) -- Explore
  SLSA levels and provenance requirements in depth
- [Sigstore Keyless Signing](https://docs.sigstore.dev/cosign/keyless/) -- Sign
  without managing keys using OIDC identity
- [SLSA Framework](https://slsa.dev/) -- Understand SLSA levels and supply
  chain security requirements
