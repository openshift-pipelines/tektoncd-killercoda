# Inspect the attestation

Beyond the image signature, Chains also attaches an **SLSA provenance
attestation** to the image. This attestation contains metadata about the build
process: what source was used, what steps ran, and what parameters were provided.

## Verify the attestation exists

Use cosign to verify and extract the SLSA provenance attestation:

```bash
cosign verify-attestation --key cosign.pub \
  --type slsaprovenance \
  --insecure-ignore-tlog --allow-insecure-registry \
  localhost:5000/test-image:latest 2>&1
```

If the attestation exists and is valid, cosign prints the attestation payload.

## Extract and inspect the provenance

Let's extract the attestation payload and inspect it:

```bash
cosign verify-attestation --key cosign.pub \
  --type slsaprovenance \
  --insecure-ignore-tlog --allow-insecure-registry \
  localhost:5000/test-image:latest 2>/dev/null \
  | jq -r '.payload' | base64 -d | python3 -m json.tool
```

You should see a JSON document in the SLSA provenance format containing:

- **`_type`**: `https://in-toto.io/Statement/v0.1` -- the in-toto attestation format
- **`predicateType`**: `https://slsa.dev/provenance/v0.2` -- SLSA provenance
- **`subject`**: the image URL and digest that was built
- **`predicate.buildType`**: `tekton.dev/v1beta1/TaskRun`
- **`predicate.invocation`**: parameters and configuration used to build

## What this means for production

In a production environment, this attestation proves:

1. **What was built** -- the exact image digest
2. **How it was built** -- the Tekton Task that ran
3. **What parameters were used** -- the image URL, any build args
4. **When it was built** -- timestamps from the TaskRun

Policy engines like [Kyverno](https://kyverno.io/) or [OPA
Gatekeeper](https://open-policy-agent.github.io/gatekeeper/) can verify these
attestations before allowing images to be deployed, enforcing that only images
built by your CI/CD system with approved configurations are allowed to run.

## The complete build-sign-verify lifecycle

```
Source code --> Tekton builds image --> Pushes to registry
                                            |
                                     Chains detects image results
                                            |
                                     Signs image with private key
                                            |
                                     Attaches SLSA provenance
                                            |
                                     At deploy time: cosign verify
```

You have now completed the full lifecycle: build, sign, attest, and verify.
