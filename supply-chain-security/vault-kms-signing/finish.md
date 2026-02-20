# Congratulations!

You have learned how to use **HashiCorp Vault's Transit engine** as a KMS
backend for Tekton Chains signing.

## What you learned

- Setting up Vault's **Transit secrets engine** with an ECDSA-P256 signing key
- Configuring Chains to use **Vault KMS** instead of local signing keys
- The signing flow where the **private key never leaves Vault**
- Verifying signatures using Vault's verify API and exported public keys

## Key points to remember

- Vault Transit provides **encryption-as-a-service** -- keys never leave Vault
- Configure with `signers.kms.kmsref: hashivault://key-name` in chains-config
- In production, use **Kubernetes auth** instead of root token
- Vault supports **key rotation** while keeping old signatures valid
- Every signing operation is logged in Vault's **audit log**

## Real-world use cases

- **Enterprise compliance**: FIPS-compliant key storage
- **Multi-team signing**: Different Vault keys per team with policy-based access
- **Audit requirements**: Complete audit trail of every signing operation
- **Key lifecycle**: Automated rotation, versioning, and revocation

## What's next

- [Transparency Logs](https://killercoda.com/tekton/course/supply-chain-security/transparency-logs) - Publish signing events to Rekor
- [Policy Enforcement](https://killercoda.com/tekton/course/supply-chain-security/policy-enforcement-kyverno) - Block unsigned images with Kyverno
- [Vault Transit documentation](https://developer.hashicorp.com/vault/docs/secrets/transit) - Full Transit engine reference
