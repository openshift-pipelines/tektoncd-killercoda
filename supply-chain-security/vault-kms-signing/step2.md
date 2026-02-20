# Sign TaskRuns using Vault KMS

Now that Chains is configured to use Vault, let's run a TaskRun and see the
signing happen through Vault's Transit engine.

## Create a build Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: vault-signed-build
spec:
  results:
    - name: IMAGE_DIGEST
      type: string
    - name: IMAGE_URL
      type: string
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Building application..."
        DIGEST="sha256:\$(head -c 32 /dev/urandom | sha256sum | cut -d' ' -f1)"
        echo -n "\$DIGEST" > \$(results.IMAGE_DIGEST.path)
        echo -n "registry.example.com/vault-app:v1" > \$(results.IMAGE_URL.path)
        echo "Build complete! Digest: \$DIGEST"
EOF
```

## Run the TaskRun

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: vault-signed-build-
spec:
  taskRef:
    name: vault-signed-build
EOF
```

## Wait for Chains to sign

Chains will detect the completed TaskRun and sign it using Vault's Transit
engine. This may take 30-60 seconds:

```bash
echo "Waiting for Chains to sign via Vault KMS..."
sleep 45

TASKRUN=$(kubectl get taskrun -l tekton.dev/task=vault-signed-build -o name | head -1)
echo "TaskRun: $TASKRUN"
```

## Compare: local signing vs Vault KMS

The key difference in the signing flow:

```bash
echo "=== Local x509 Signing ==="
echo "  1. Chains loads private key from Kubernetes Secret"
echo "  2. Chains signs the payload locally (key in memory)"
echo "  3. Signature stored as TaskRun annotation"
echo ""
echo "=== Vault KMS Signing ==="
echo "  1. Chains sends the hash to Vault Transit API"
echo "  2. Vault signs using the key that NEVER leaves Vault"
echo "  3. Vault returns only the signature"
echo "  4. Signature stored as TaskRun annotation"
echo ""
echo "The private key never leaves Vault in the KMS flow!"
```

## Check the signing annotations

```bash
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=vault-signed-build -o name | head -1)

echo "=== Chains Annotations ==="
kubectl get $TASKRUN -o json | python3 -c "
import sys, json
data = json.load(sys.stdin)
annotations = data.get('metadata', {}).get('annotations', {})
for k, v in sorted(annotations.items()):
    if 'chains' in k:
        val = v[:80] + '...' if len(v) > 80 else v
        print(f'  {k}: {val}')
" 2>/dev/null || kubectl get $TASKRUN -o jsonpath='{.metadata.annotations}' | tr ',' '\n' | grep chains
```

## Verify

Confirm the TaskRun was signed:

```bash
TASKRUN=$(kubectl get taskrun -l tekton.dev/task=vault-signed-build -o name | head -1)
kubectl get $TASKRUN -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null
echo ""
```
