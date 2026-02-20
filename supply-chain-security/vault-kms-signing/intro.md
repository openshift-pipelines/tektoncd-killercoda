# Signing with HashiCorp Vault KMS

By default, Tekton Chains generates and stores signing keys as Kubernetes
Secrets. While this works for development, production environments need
**centralized key management** where keys never leave a secure boundary.

**HashiCorp Vault's Transit secrets engine** provides encryption-as-a-service:
signing keys are generated inside Vault and the private key material never
leaves the Vault process. Chains sends data to Vault for signing and gets back
the signature -- the key itself is never exposed.

This is the KMS (Key Management Service) pattern used by enterprises for:

- **Key lifecycle management**: Rotation, versioning, and revocation
- **Audit logging**: Every signing operation is logged in Vault's audit log
- **Access control**: Vault policies control who can sign and what
- **Compliance**: Keys stored in a FIPS-compliant boundary

In this tutorial, you will learn:

- How to set up Vault's **Transit engine** as a Chains signing backend
- How to **sign TaskRuns** with keys that never leave Vault
- How to **verify signatures** using the public key exported from Vault

**Prerequisites:** Familiarity with Tekton Chains (covered in Intro to Chains).

While the environment loads, Tekton Pipelines, Chains, and Vault (dev mode) are
being installed. This may take a minute or two.
