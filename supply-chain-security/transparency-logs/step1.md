# Understand and configure transparency logs

Transparency logs provide a public, auditable record of signing events. Let's
configure Chains to publish to Rekor and run a TaskRun.

## How Rekor works with Chains

When Chains signs a TaskRun:

1. Chains creates a signature (x509 or cosign)
2. If transparency logging is enabled, Chains **uploads the signing event to Rekor**
3. Rekor returns a **log entry** with an index number and inclusion proof
4. Chains stores the Rekor log entry ID as an annotation on the TaskRun

## Configure Chains for transparency logging

Check the current Chains configuration:

```bash
kubectl get configmap chains-config -n tekton-chains -o yaml
```

Configure Chains to use cosign-based signing with transparency:

```bash
kubectl patch configmap chains-config -n tekton-chains -p '{"data":{
  "artifacts.taskrun.format": "in-toto",
  "artifacts.taskrun.storage": "tekton",
  "transparency.enabled": "true",
  "signers.x509.fulcio.enabled": "false"
}}'
```

Restart the Chains controller to pick up the configuration:

```bash
kubectl delete pod -l app=tekton-chains-controller -n tekton-chains
kubectl wait --for=condition=ready pod -l app=tekton-chains-controller \
  -n tekton-chains --timeout=120s
```

## Create and run a TaskRun

Create a simple build Task and run it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-artifact
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
        echo "Building artifact..."
        echo -n "sha256:$(head -c 32 /dev/urandom | sha256sum | cut -d' ' -f1)" > \$(results.IMAGE_DIGEST.path)
        echo -n "registry.example.com/my-app:latest" > \$(results.IMAGE_URL.path)
        echo "Build complete!"
EOF

cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: build-artifact-
spec:
  taskRef:
    name: build-artifact
EOF
```

Wait for Chains to process the TaskRun (this may take 30-60 seconds):

```bash
echo "Waiting for Chains to sign the TaskRun..."
sleep 45
```

## Verify

Confirm Chains is configured for transparency:

```bash
kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.transparency\.enabled}'
echo ""
```
