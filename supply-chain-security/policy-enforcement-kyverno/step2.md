# Create an image verification policy

Now you will create a Kyverno **ClusterPolicy** that verifies cosign signatures
on all container images deployed to the `secure-deployments` namespace.

## Read the cosign public key

First, check that the public key was generated:

```bash
cat cosign.pub
```

This is the public key that corresponds to the private key stored in the
`signing-secrets` Secret in the `tekton-chains` namespace.

## Create the image verification policy

Create a ClusterPolicy that uses the `verifyImages` rule to require cosign
signatures on all images in the `secure-deployments` namespace:

```bash
COSIGN_PUB=$(cat cosign.pub)
cat <<EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signatures
spec:
  validationFailureAction: Enforce
  background: false
  rules:
    - name: verify-cosign-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
              namespaces:
                - secure-deployments
      verifyImages:
        - imageReferences:
            - "localhost:5000/*"
          attestors:
            - count: 1
              entries:
                - keys:
                    publicKeys: |-
                      ${COSIGN_PUB}
                    signatureAlgorithm: sha256
          required: true
EOF
```

## Verify the policy was created

```bash
kubectl get clusterpolicy verify-image-signatures
```

## Inspect the policy details

```bash
kubectl get clusterpolicy verify-image-signatures -o yaml | head -40
```

## Understand the policy

The policy you created:

- **Scope**: Applies only to Pods in the `secure-deployments` namespace
- **Image pattern**: Matches images from `localhost:5000/*` (the local registry)
- **Verification**: Requires a valid cosign signature using your public key
- **Action**: `Enforce` mode means unsigned images are **blocked** (not just
  warned about)
- **Attestors**: Specifies that exactly 1 cosign key attestor must verify
  successfully

This means:

- Images signed by Chains (which uses the corresponding private key) will
  **pass** verification
- Images without a signature (or signed by a different key) will be **rejected**

The policy is now active and enforcing signature verification.
