# Verify supply chain integrity as a consumer

In a real deployment workflow, the consumer (deployer) does not have access to
the signing private key. They only have the **public key** and use it to verify
that images came from the trusted build system.

## Simulate a consumer environment

Copy only the public key to a separate directory, simulating a consumer who
received just the public key:

```bash
mkdir -p /root/consumer
cp cosign.pub /root/consumer/
ls -la /root/consumer/
```

The consumer has **only the public key** -- no access to the private key or the
build system.

## Verify the image signature as a consumer

Using only the public key, verify that the image was signed by the trusted
build system:

```bash
cosign verify \
  --key /root/consumer/cosign.pub \
  --insecure-ignore-tlog=true \
  --allow-insecure-registry \
  localhost:5000/secure-app:v1
```

A successful verification proves:

- The image was signed with the private key matching this public key
- The image has not been tampered with since signing

## Verify the SLSA provenance attestation

The consumer can also inspect the provenance attestation to understand **how**
the image was built:

```bash
cosign verify-attestation \
  --key /root/consumer/cosign.pub \
  --insecure-ignore-tlog=true \
  --allow-insecure-registry \
  --type slsaprovenance \
  localhost:5000/secure-app:v1 2>&1 | \
  python3 -c "
import sys, json, base64
for line in sys.stdin:
    line = line.strip()
    if not line or line.startswith('Verification'):
        continue
    try:
        payload = json.loads(line)
        if 'payload' in payload:
            decoded = json.loads(base64.b64decode(payload['payload']))
            print(json.dumps(decoded, indent=2))
            break
    except:
        pass
" 2>/dev/null || echo "Attestation verified (raw output above)."
```

The provenance attestation tells the consumer:

- **What was built** -- the image digest
- **How it was built** -- the Tekton Pipeline/Task that ran
- **When it was built** -- timestamps of the build process
- **Build materials** -- source inputs to the build

## Demonstrate a tampered image is rejected

To show that verification actually works, try verifying with a wrong key:

```bash
cd /tmp
COSIGN_PASSWORD="" cosign generate-key-pair 2>/dev/null
cosign verify \
  --key /tmp/cosign.pub \
  --insecure-ignore-tlog=true \
  --allow-insecure-registry \
  localhost:5000/secure-app:v1 2>&1 || \
  echo "EXPECTED: Verification failed -- wrong key!"
cd /root
```

This confirms that only the correct public key can verify the image,
protecting against supply chain attacks.

## Check what is stored in the registry

List all tags and artifacts in the registry to see both the image and its
signature:

```bash
curl -s http://localhost:5000/v2/secure-app/tags/list | python3 -m json.tool
```

You will see the `v1` tag plus additional signature-related tags that Chains
created. These are the cosign signature and attestation payloads stored
alongside the image in the same OCI registry.
