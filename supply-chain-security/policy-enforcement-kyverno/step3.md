# Deploy a signed image (allowed)

Now you will build an image with Tekton, let Chains sign it, and then deploy it
to the policy-enforced namespace. Kyverno should allow the deployment because
the image is signed.

## Create the build Task

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-signed-image
spec:
  params:
    - name: IMAGE
      type: string
  results:
    - name: IMAGE_URL
      description: The image URL
    - name: IMAGE_DIGEST
      description: The image digest
  steps:
    - name: build-push
      image: gcr.io/kaniko-project/executor:v1.23.2
      args:
        - --dockerfile=/workspace/Dockerfile
        - --context=/workspace
        - --destination=$(params.IMAGE)
        - --digest-file=$(results.IMAGE_DIGEST.path)
        - --insecure
    - name: write-url
      image: alpine:3.19
      script: |
        #!/bin/sh
        printf "%s" "$(params.IMAGE)" > $(results.IMAGE_URL.path)
  sidecars: []
EOF
```

## Create a Dockerfile inline

Create a temporary Dockerfile for building:

```bash
mkdir -p /root/policy-app
cat > /root/policy-app/Dockerfile << 'DOCKERFILE'
FROM alpine:3.19
RUN echo '#!/bin/sh' > /app.sh && echo 'echo "I am a signed image!"' >> /app.sh && chmod +x /app.sh
CMD ["/app.sh"]
DOCKERFILE
```

## Build the image with Tekton

Create a TaskRun that builds and pushes the image. Chains will automatically
sign it:

```bash
cat <<'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: build-signed-
spec:
  taskSpec:
    results:
      - name: IMAGE_URL
        description: The image URL
      - name: IMAGE_DIGEST
        description: The image digest
    steps:
      - name: create-dockerfile
        image: alpine:3.19
        script: |
          #!/bin/sh
          mkdir -p /workspace/source
          cat > /workspace/source/Dockerfile << 'INNEREOF'
          FROM alpine:3.19
          RUN echo "I am a signed image" > /message.txt
          CMD ["cat", "/message.txt"]
          INNEREOF
      - name: build-push
        image: gcr.io/kaniko-project/executor:v1.23.2
        args:
          - --dockerfile=/workspace/source/Dockerfile
          - --context=/workspace/source
          - --destination=localhost:5000/signed-app:v1
          - --digest-file=/tekton/results/IMAGE_DIGEST
          - --insecure
      - name: write-url
        image: alpine:3.19
        script: |
          #!/bin/sh
          printf "localhost:5000/signed-app:v1" > /tekton/results/IMAGE_URL
EOF
```

## Wait for the build to complete

```bash
TR_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "TaskRun: $TR_NAME"
kubectl wait --for=condition=Succeeded taskrun "$TR_NAME" --timeout=300s
```

## Wait for Chains to sign the image

```bash
TR_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "Waiting for Chains to sign..."
for i in $(seq 1 30); do
  SIGNED=$(kubectl get taskrun "$TR_NAME" -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null)
  if [ "$SIGNED" = "true" ]; then
    echo "Image signed by Chains!"
    break
  fi
  echo "  Waiting... ($i/30)"
  sleep 5
done
```

## Verify the signature exists

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true \
  --allow-insecure-registry localhost:5000/signed-app:v1 2>&1 | head -5
```

## Deploy the signed image to the policy-enforced namespace

Now deploy the signed image. Kyverno should allow it:

```bash
TR_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
IMAGE_DIGEST=$(kubectl get taskrun "$TR_NAME" -o jsonpath='{.status.results[?(@.name=="IMAGE_DIGEST")].value}')

kubectl create deployment signed-app \
  --image="localhost:5000/signed-app@${IMAGE_DIGEST}" \
  --namespace=secure-deployments
```

## Verify the deployment was allowed

```bash
kubectl get deployment signed-app -n secure-deployments
kubectl get pods -n secure-deployments
```

Kyverno verified the cosign signature and allowed the deployment. The signed
image passed the policy check.
