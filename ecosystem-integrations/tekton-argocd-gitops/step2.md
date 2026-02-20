# Create a Tekton CI Pipeline

Now that the GitOps repository is set up, you need a CI pipeline that builds
your application and updates the manifests in the GitOps repo. This is the
Tekton side of the CI/CD equation.

In a real-world scenario, Tekton would clone your application source code, run
tests, build a container image, and then update the image tag in your GitOps
repository. For this tutorial, we simulate the build and test steps and focus on
the GitOps update workflow.

## Create the CI Tasks

First, create a Task that simulates running tests on your application code:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: run-tests
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Running unit tests..."
        sleep 2
        echo "All 42 tests passed."
EOF
```

Next, create a Task that simulates building a container image and returns the
new image tag:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-image
spec:
  results:
    - name: image-tag
      description: The new image tag
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/bin/sh
        NEW_TAG="1.25"
        echo "Building container image with tag: \${NEW_TAG}"
        sleep 2
        echo "Image built successfully."
        echo -n "\${NEW_TAG}" > \$(results.image-tag.path)
EOF
```

Now create the most important Task - the one that updates the GitOps
repository with the new image tag. This Task clones the repo using the `git://`
protocol so it can access the git server from inside the pod:

```bash
NODE_IP=$(cat /tmp/node-ip)
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: update-manifests
spec:
  params:
    - name: image-tag
      type: string
      description: The new image tag to deploy
    - name: git-repo-url
      type: string
      description: The git repository URL
  steps:
    - name: update-and-push
      image: alpine/git:2.43.0
      script: |
        #!/bin/sh
        set -e
        git clone \$(params.git-repo-url) /workspace/repo
        cd /workspace/repo
        git config user.email "tekton@example.com"
        git config user.name "Tekton CI"

        # Update the image tag in the deployment manifest
        sed -i "s|image: nginx:.*|image: nginx:\$(params.image-tag)|" manifests/deployment.yaml

        echo "Updated deployment to nginx:\$(params.image-tag)"
        cat manifests/deployment.yaml

        git add .
        git commit -m "Update image to nginx:\$(params.image-tag)"
        git push origin master
        echo "Pushed updated manifests to GitOps repo."
EOF
```

## Create the CI Pipeline

Wire the Tasks together into a Pipeline. The pipeline runs tests, builds the
image, and then updates the GitOps repository:

```bash
NODE_IP=$(cat /tmp/node-ip)
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: gitops-ci
spec:
  params:
    - name: git-repo-url
      type: string
      default: "git://${NODE_IP}/gitops-repo.git"
  tasks:
    - name: run-tests
      taskRef:
        name: run-tests
    - name: build-image
      runAfter:
        - run-tests
      taskRef:
        name: build-image
    - name: update-manifests
      runAfter:
        - build-image
      params:
        - name: image-tag
          value: \$(tasks.build-image.results.image-tag)
        - name: git-repo-url
          value: \$(params.git-repo-url)
      taskRef:
        name: update-manifests
EOF
```

Verify the Pipeline was created:

```bash
tkn pipeline list
```

You should see the `gitops-ci` pipeline. This pipeline follows the standard
CI/CD pattern:

1. **run-tests** - Validate the application code
2. **build-image** - Build the container image and produce an image tag
3. **update-manifests** - Push the new image tag to the GitOps repository

The `update-manifests` Task receives the image tag from `build-image` via
Tekton's result passing mechanism, then commits and pushes the change to the
GitOps repo. ArgoCD will detect this change and deploy it.
