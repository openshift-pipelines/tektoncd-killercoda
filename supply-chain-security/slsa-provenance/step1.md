# Generate SLSA provenance with Chains

In this step, we will configure Tekton Chains to produce SLSA v1 provenance
attestations, set up signing keys, run a TaskRun, and wait for Chains to sign
it.

## Generate signing keys

Chains needs a key pair to sign attestations. Use cosign to generate one and
store it as a Kubernetes Secret:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

Press Enter if prompted for a password. This creates:
- A private key in the `signing-secrets` Secret (used by Chains)
- A public key `cosign.pub` in your current directory (used for verification)

Verify the Secret was created:

```bash
kubectl get secret signing-secrets -n tekton-chains
```

## Configure Chains for SLSA v1 provenance

Configure Chains to output provenance in SLSA v1 format and store it as
Tekton annotations on the TaskRun:

```bash
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{
  "artifacts.taskrun.format":"slsa/v1",
  "artifacts.taskrun.storage":"tekton"
}}'
```

The key settings:
- `artifacts.taskrun.format: slsa/v1` - produce SLSA v1 provenance (in-toto
  attestation format)
- `artifacts.taskrun.storage: tekton` - store the signature and payload as
  annotations on the TaskRun object

## Restart the Chains controller

Restart Chains to pick up the new configuration:

```bash
kubectl delete pod -l app.kubernetes.io/part-of=tekton-chains -n tekton-chains
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=60s
```

## Create and run a Task

Create a Task that simulates a build process with identifiable inputs:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-artifact
spec:
  params:
    - name: git-repo
      type: string
      default: "https://github.com/tektoncd/pipeline"
    - name: git-revision
      type: string
      default: "main"
  steps:
    - name: clone
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Cloning \$(params.git-repo) at \$(params.git-revision)..."
        echo "Clone complete."
    - name: build
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Building artifact from source..."
        echo "Build complete. Artifact: myapp-v1.0.0.tar.gz"
    - name: checksum
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Computing SHA256 checksum..."
        echo "sha256:abc123def456 myapp-v1.0.0.tar.gz"
EOF
```

## Run the Task

<!-- e2e-skip -->
```bash
tkn task start build-artifact \
  -p git-repo="https://github.com/tektoncd/pipeline" \
  -p git-revision="v0.50.0" \
  --showlog
```

Start the task without following logs (for CI):

```bash
tkn task start build-artifact \
  -p git-repo="https://github.com/tektoncd/pipeline" \
  -p git-revision="v0.50.0"
sleep 10
```

## Wait for Chains to sign

Chains watches for completed TaskRuns and signs them asynchronously. Wait for
the signing to complete:

```bash
echo "Waiting for Chains to sign the TaskRun..."
TASKRUN_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
for i in $(seq 1 30); do
  SIGNED=$(kubectl get taskrun "$TASKRUN_NAME" -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null)
  if [ "$SIGNED" = "true" ]; then
    echo "TaskRun signed after ${i} seconds!"
    break
  fi
  sleep 2
done
```

## Verify signing

Confirm the TaskRun has been signed:

<!-- e2e-skip -->
```bash
kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}'
echo ""
```

You should see `true`. The SLSA provenance attestation is now stored as
annotations on this TaskRun.
