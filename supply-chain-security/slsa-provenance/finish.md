# Congratulations!

You have completed the SLSA Provenance Deep Dive and now understand how Tekton
Chains generates, signs, and stores provenance attestations.

## What you learned

- **Configuring Chains** - how to set `artifacts.taskrun.format` to `slsa/v1`
  and `artifacts.taskrun.storage` to `tekton`
- **SLSA provenance format** - the structure of an in-toto attestation
  including `subject`, `predicate`, `buildType`, `invocation`, `buildConfig`,
  and `materials`
- **SLSA levels** - what L1 through L4 mean and that Chains provides L1
  (provenance exists) and L2 (signed provenance) out of the box
- **Signature verification** - how to use `cosign verify-blob` with the
  `--insecure-ignore-tlog` flag to verify provenance signatures

## Next steps

- [SLSA specification](https://slsa.dev/spec/v1.0/) - The full SLSA specification
- [Tekton Chains documentation](https://tekton.dev/docs/chains/) - Full Chains documentation
- [Sigstore and cosign](https://docs.sigstore.dev/) - Learn more about the signing ecosystem
- [Tekton documentation](https://tekton.dev/docs/) - Full documentation for all Tekton components
