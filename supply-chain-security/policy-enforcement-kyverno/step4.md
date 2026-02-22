# Deploy an unsigned image (blocked)

Now you will push an image **without** Tekton Chains signing it and attempt to
deploy it to the policy-enforced namespace. Kyverno should block the deployment.

## Push an unsigned image directly (bypassing Tekton)

Use Docker to build and push an image directly to the registry, without going
through Tekton or Chains. This image will have **no cosign signature**:

```bash
mkdir -p /root/unsigned-app
cat > /root/unsigned-app/Dockerfile << 'DOCKERFILE'
FROM alpine:3.19
RUN echo "I am an UNSIGNED image -- I should be blocked!" > /message.txt
CMD ["cat", "/message.txt"]
DOCKERFILE
```

Build and push directly with Docker (no Tekton, no Chains signing):

```bash
docker build -t localhost:5000/unsigned-app:v1 /root/unsigned-app/
docker push localhost:5000/unsigned-app:v1
```

## Confirm the image has no signature

Try to verify the image -- it should fail because there is no signature:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true \
  --allow-insecure-registry localhost:5000/unsigned-app:v1 2>&1 || \
  echo "No valid signature found (expected)."
```

## Attempt to deploy the unsigned image (should be blocked)

Now try to deploy this unsigned image to the policy-enforced namespace:

```bash
kubectl create deployment unsigned-app \
  --image=localhost:5000/unsigned-app:v1 \
  --namespace=secure-deployments 2>&1 || true
```

## Examine the rejection

Kyverno should have blocked this deployment. Check the events for details:

```bash
kubectl get events -n secure-deployments --sort-by='.lastTimestamp' | tail -10
```

You can also check the Kyverno policy report for details:

```bash
kubectl get policyreport -n secure-deployments -o yaml 2>/dev/null | head -30 || \
  echo "No policy report yet (this is normal for blocked requests)."
```

## Verify: signed image is running, unsigned is blocked

Confirm the state of both deployments:

```bash
echo "=== Deployments in secure-deployments namespace ==="
kubectl get deployments -n secure-deployments
echo ""
echo "=== Pods in secure-deployments namespace ==="
kubectl get pods -n secure-deployments
```

You should see:

- **signed-app**: Running successfully (deployed in Step 3)
- **unsigned-app**: Either not present (creation was blocked) or present but
  with 0 ready pods (Pod creation was blocked)

## Understand the security model

This demonstrates the complete **build-time signing + deploy-time enforcement**
model:

```
Tekton Chains (Build Time)          Kyverno (Deploy Time)
========================          ========================
Build image --> Sign it     -->   Verify signature --> Allow/Deny
                                        |
                              Public key matches? --> Deploy!
                              No signature?       --> BLOCKED!
                              Wrong key?           --> BLOCKED!
```

The combination of Tekton Chains and Kyverno ensures that **only images built
by your trusted CI/CD pipeline can be deployed** to your cluster. Any image
that bypasses your build system will be rejected at deploy time.
