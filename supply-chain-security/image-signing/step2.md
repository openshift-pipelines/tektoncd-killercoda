# Build and push a container image

Now let's create a Task that builds a container image and pushes it to our local
registry. For Chains to detect and sign the image, the Task must emit specific
**results** that Chains recognizes.

## Create the image-building Task

This Task uses [Kaniko](https://github.com/GoogleContainerTools/kaniko) to build
a Dockerfile and push the resulting image to the local registry:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-push-image
spec:
  params:
    - name: IMAGE
      type: string
      description: The image URL to push to
  results:
    - name: IMAGE_URL
      description: The URL of the built image
    - name: IMAGE_DIGEST
      description: The digest of the built image
  steps:
    - name: create-dockerfile
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        cat > /workspace/Dockerfile <<DOCKERFILE
        FROM alpine:3.18
        LABEL maintainer="tekton-tutorial"
        RUN echo "Hello from Tekton Chains image signing tutorial!" > /hello.txt
        CMD ["cat", "/hello.txt"]
        DOCKERFILE
        echo "Dockerfile created"
    - name: build-and-push
      image: gcr.io/kaniko-project/executor:latest
      args:
        - --dockerfile=/workspace/Dockerfile
        - --context=/workspace
        - --destination=$(params.IMAGE)
        - --insecure
        - --digest-file=$(results.IMAGE_DIGEST.path)
      env:
        - name: DOCKER_CONFIG
          value: /workspace/.docker
    - name: write-url
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo -n "$(params.IMAGE)" > $(results.IMAGE_URL.path)
        echo "Image URL written: $(params.IMAGE)"
EOF
```

The key parts for Chains are the **results**:
- `IMAGE_URL` -- tells Chains which image was built
- `IMAGE_DIGEST` -- tells Chains the exact content hash of the image

Chains uses these result names (by convention) to find and sign images.

## Run the Task

Run the Task, pushing the image to our local registry:

```bash
tkn task start build-push-image \
  --param IMAGE=localhost:5000/test-image:latest \
  --showlog
```

Wait for the TaskRun to complete. You should see Kaniko build the image and push
it to `localhost:5000/test-image:latest`.

## Verify the image is in the registry

```bash
curl -s http://localhost:5000/v2/_catalog
```

You should see `test-image` listed in the registry catalog.

Check the tags:

```bash
curl -s http://localhost:5000/v2/test-image/tags/list
```

You should see the `latest` tag.
