# Transparency Logs with Rekor

**Transparency logs** are append-only, tamper-evident ledgers that record signing
events. When Tekton Chains signs a build, the signature event can be published to
a transparency log so that anyone can independently verify it happened.

**Rekor** (part of the Sigstore project) is the transparency log used by Tekton
Chains. Every time Chains signs a TaskRun, it can publish the signing event to
Rekor, creating an immutable record that:

- Proves the signature was created at a specific time
- Allows third-party auditing without trusting the signer
- Detects if a signing key is compromised (certificate transparency model)

In this tutorial, you will learn:

- How to configure Tekton Chains to use Rekor for **transparency logging**
- How to **find your signing event** in the Rekor log after a TaskRun
- How to **verify entries** using the `rekor-cli` tool

**Prerequisites:** Familiarity with Tekton Chains and image signing (covered in
the Intro to Chains and Image Signing tutorials).

While the environment loads, Tekton Pipelines, Chains, cosign, and the rekor-cli
are being installed. This may take a minute or two.
