# Congratulations!

You have learned how **transparency logs** work with Tekton Chains and Rekor to
create auditable, tamper-evident records of your CI/CD signing events.

## What you learned

- **Transparency logs** are append-only ledgers that record signing events
- **Rekor** (Sigstore) is the transparency log used by Tekton Chains
- How to **configure Chains** to publish signing events to Rekor
- How to **find and inspect** log entries using rekor-cli and annotations
- The **verification model**: inclusion proofs, consistency proofs, signed timestamps

## Key points to remember

- Enable with `transparency.enabled: "true"` in chains-config
- Chains stores the Rekor entry reference as a TaskRun annotation
- The public Rekor instance is at `rekor.sigstore.dev`
- Transparency logs enable third-party auditing without trusting the signer
- Log entries are immutable -- compromise is detectable

## Real-world use cases

- **Compliance auditing**: Prove builds were signed at specific times
- **Incident response**: Detect unauthorized signing after key compromise
- **Supply chain requirements**: Meet SLSA Level 3+ transparency requirements
- **Multi-party verification**: Let consumers verify without trusting producers

## What's next

- [SLSA Provenance](https://killercoda.com/tekton/course/supply-chain-security/slsa-provenance) - Generate and inspect provenance attestations
- [End-to-End Secure Pipeline](https://killercoda.com/tekton/course/supply-chain-security/end-to-end-secure-pipeline) - Complete build-sign-verify lifecycle
- [Sigstore documentation](https://docs.sigstore.dev/) - Full Sigstore ecosystem reference
