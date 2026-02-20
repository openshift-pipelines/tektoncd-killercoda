# Authenticate with a container registry

When your pipeline builds container images, it needs credentials to push them
to a container registry (Docker Hub, quay.io, GitHub Container Registry, etc.).

Tekton supports two approaches for Docker registry authentication:

| Secret Type | Use Case |
|-------------|----------|
| `kubernetes.io/basic-auth` with `tekton.dev/docker-*` annotation | Username + password, Tekton generates `~/.docker/config.json` |
| `kubernetes.io/dockerconfigjson` | Use an existing Docker config directly |

## Option 1: basic-auth with Docker annotation

This approach is symmetric with Git auth — use a `basic-auth` Secret but with
a `tekton.dev/docker-*` annotation instead of `tekton.dev/git-*`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: registry-credentials
  annotations:
    tekton.dev/docker-0: https://index.docker.io/v1/
type: kubernetes.io/basic-auth
stringData:
  username: my-docker-user
  password: my-docker-password
EOF
```

For other registries, change the annotation value:
- **quay.io**: `tekton.dev/docker-0: https://quay.io`
- **GitHub Container Registry**: `tekton.dev/docker-0: https://ghcr.io`
- **Google Container Registry**: `tekton.dev/docker-0: https://gcr.io`

## Option 2: dockerconfigjson Secret

If you already have a Docker config file, you can use it directly:

```bash
kubectl create secret docker-registry registry-credentials-v2 \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=my-docker-user \
  --docker-password=my-docker-password
```

This creates a `kubernetes.io/dockerconfigjson` type Secret.

## Create a ServiceAccount with both Git and registry Secrets

In a real pipeline, you often need both Git and registry credentials. Create a
ServiceAccount that has both:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-bot
secrets:
  - name: git-credentials
  - name: registry-credentials
EOF
```

## Verify the setup

```bash
kubectl get serviceaccount build-bot -o yaml
```

You should see both `git-credentials` and `registry-credentials` listed.

## How registry auth works

When a Task runs with this ServiceAccount, Tekton creates a
`~/.docker/config.json` file:

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "<base64(username:password)>"
    }
  }
}
```

Build tools like Buildah, Kaniko, and `docker push` automatically read this
config when pushing images.

## Test that credentials are injected

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: auth-test-
spec:
  serviceAccountName: build-bot
  taskSpec:
    steps:
      - name: check-credentials
        image: ubuntu:22.04
        script: |
          #!/usr/bin/env bash
          echo "=== Checking Git credentials ==="
          if [ -f ~/.gitconfig ]; then
            echo "~/.gitconfig found:"
            cat ~/.gitconfig
          else
            echo "No ~/.gitconfig (credentials may still be initializing)"
          fi
          echo ""
          echo "=== Checking Docker credentials ==="
          if [ -f ~/.docker/config.json ]; then
            echo "~/.docker/config.json found!"
          else
            echo "No ~/.docker/config.json (credentials may still be initializing)"
          fi
          echo ""
          echo "Authentication injection verified!"
EOF
```

Check the logs:

```bash
tkn taskrun logs --last -f
```
