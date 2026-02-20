# Build a Pipeline that clones, builds, signs, and attests

Now you will create the individual Tasks and wire them into a multi-task
Pipeline. The Pipeline will clone a local repository, build an image with
Kaniko, and Chains will automatically handle signing.

## Create the clone-repo Task

This Task copies source code from a local directory into a shared workspace:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: clone-repo
spec:
  params:
    - name: source-dir
      type: string
      description: Path to the local source directory
  workspaces:
    - name: output
      description: The workspace to write source files to
  results:
    - name: commit
      description: The git commit SHA
  steps:
    - name: clone
      image: alpine:3.19
      script: |
        #!/bin/sh
        set -e
        cp -r "$(params.source-dir)"/* $(workspaces.output.path)/
        cd "$(params.source-dir)"
        if command -v git >/dev/null 2>&1 && [ -d .git ]; then
          COMMIT=$(git rev-parse HEAD)
        else
          COMMIT="local-build"
        fi
        printf "%s" "$COMMIT" > $(results.commit.path)
        echo "Source copied. Commit: $COMMIT"
EOF
```

## Create the build-and-push Task

This Task builds a container image using Kaniko and emits the `IMAGE_URL` and
`IMAGE_DIGEST` results that Chains needs to detect and sign the image:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-and-push
spec:
  params:
    - name: IMAGE
      type: string
      description: The image URL to build and push
  workspaces:
    - name: source
      description: The workspace containing the source and Dockerfile
  results:
    - name: IMAGE_URL
      description: The URL of the built image
    - name: IMAGE_DIGEST
      description: The digest of the built image
  steps:
    - name: build-push
      image: gcr.io/kaniko-project/executor:v1.23.2
      args:
        - --dockerfile=$(workspaces.source.path)/Dockerfile
        - --context=$(workspaces.source.path)
        - --destination=$(params.IMAGE)
        - --digest-file=$(results.IMAGE_DIGEST.path)
        - --insecure
      env:
        - name: DOCKER_CONFIG
          value: /tekton/home/.docker
    - name: write-url
      image: alpine:3.19
      script: |
        #!/bin/sh
        printf "%s" "$(params.IMAGE)" > $(results.IMAGE_URL.path)
        echo "Image URL: $(params.IMAGE)"
        echo "Image Digest: $(cat $(results.IMAGE_DIGEST.path))"
EOF
```

**Important**: The result names `IMAGE_URL` and `IMAGE_DIGEST` are the
convention that Chains looks for. When a TaskRun emits both of these results,
Chains automatically signs the corresponding image in the registry.

## Create the verify-signature Task

This Task verifies the image signature using cosign after Chains has signed it:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: verify-signature
spec:
  params:
    - name: image-url
      type: string
      description: The image URL to verify
    - name: image-digest
      type: string
      description: The image digest to verify
  steps:
    - name: verify
      image: alpine:3.19
      script: |
        #!/bin/sh
        set -e
        echo "Image to verify: $(params.image-url)@$(params.image-digest)"
        echo "Signature verification will be done after the Pipeline completes"
        echo "because Chains signs asynchronously after the TaskRun succeeds."
        echo "See Step 3 for manual verification."
EOF
```

## Wire everything into a Pipeline

Create the secure Pipeline that chains all three Tasks together:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: secure-build-pipeline
spec:
  params:
    - name: source-dir
      type: string
      description: Path to local source directory
    - name: image-reference
      type: string
      description: The image to build and push
  workspaces:
    - name: shared-workspace
      description: Shared workspace for source code
  tasks:
    - name: clone
      taskRef:
        name: clone-repo
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: source-dir
          value: $(params.source-dir)
    - name: build
      taskRef:
        name: build-and-push
      runAfter:
        - clone
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.image-reference)
    - name: post-build-check
      taskRef:
        name: verify-signature
      runAfter:
        - build
      params:
        - name: image-url
          value: $(params.image-reference)
        - name: image-digest
          value: $(tasks.build.results.IMAGE_DIGEST)
EOF
```

## Verify all resources are created

```bash
tkn task list
tkn pipeline describe secure-build-pipeline
```

The Pipeline is ready. In the next step, you will run it and see Chains sign
the image automatically.
