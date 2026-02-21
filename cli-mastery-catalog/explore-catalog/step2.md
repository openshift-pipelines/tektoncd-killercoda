# Use catalog Tasks in a Pipeline

Now that you have `git-clone` installed, let's install a second catalog Task
and chain them together in a Pipeline. This demonstrates how catalog Tasks are
designed to compose with each other.

## Install the kaniko Task

The **kaniko** Task builds container images from a Dockerfile without requiring
a Docker daemon. Install it from the catalog:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml
```

## Verify both Tasks are installed

<!-- e2e-skip -->
```bash
tkn task list
```

You should see both `git-clone` and `kaniko`.

## Inspect how catalog Tasks follow conventions

Both Tasks use the **workspace convention** that makes them composable:

<!-- e2e-skip -->
```bash
echo "=== git-clone workspaces ==="
tkn task describe git-clone | grep -A 5 "Workspaces"
echo ""
echo "=== kaniko workspaces ==="
tkn task describe kaniko | grep -A 5 "Workspaces"
```

The `git-clone` Task writes to a workspace, and `kaniko` reads from a workspace.
By mapping them to the same Pipeline workspace, source code flows naturally from
one Task to the next.

## Create a Pipeline chaining both Tasks

Create a Pipeline that clones a repository and builds a container image:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: clone-and-build
spec:
  params:
    - name: repo-url
      type: string
      description: The Git repository URL to clone
    - name: image-reference
      type: string
      description: The image to build and push
  workspaces:
    - name: shared-workspace
      description: Shared workspace for source code
    - name: docker-credentials
      description: Docker config for pushing images
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.repo-url)
    - name: build-image
      taskRef:
        name: kaniko
      runAfter:
        - fetch-source
      workspaces:
        - name: source
          workspace: shared-workspace
        - name: dockerconfig
          workspace: docker-credentials
      params:
        - name: IMAGE
          value: $(params.image-reference)
EOF
```

## Verify the Pipeline

<!-- e2e-skip -->
```bash
tkn pipeline describe clone-and-build
```

Notice how the Pipeline:

- **Passes workspaces through** - `shared-workspace` connects `git-clone`
  output to `kaniko` source
- **Uses `runAfter`** - ensures `build-image` waits for `fetch-source`
- **Exposes parameters** - the Pipeline user only needs to provide a repo URL
  and image reference

This is the power of catalog Tasks: they follow conventions that make them
plug-and-play in any Pipeline.
