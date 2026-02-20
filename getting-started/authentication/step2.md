# Authenticate with a container registry

When your pipeline builds container images, it needs credentials to push them
to a container registry (Docker Hub, quay.io, GitHub Container Registry, etc.).

## Create a registry authentication Secret

For container registries, Tekton uses the `kubernetes.io/dockerconfigjson`
Secret type (created with `kubectl create secret docker-registry`):

```bash
kubectl create secret docker-registry registry-credentials \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=my-docker-user \
  --docker-password=my-docker-password
```

For other registries, change the `--docker-server`:
- **quay.io**: `--docker-server=https://quay.io`
- **GitHub Container Registry**: `--docker-server=https://ghcr.io`
- **Google Container Registry**: `--docker-server=https://gcr.io`

## Create a ServiceAccount with both Secrets

In a real pipeline, you often need both Git and registry credentials. Create a
ServiceAccount that has both:

```bash
kubectl create serviceaccount build-bot
```

```bash
kubectl patch serviceaccount build-bot \
  -p '{"secrets": [{"name": "git-credentials"}, {"name": "registry-credentials"}]}'
```

## Verify the setup

```bash
kubectl get serviceaccount build-bot -o yaml
```

You should see both `git-credentials` and `registry-credentials` listed.

## How registry auth works

When a Task uses tools like Buildah or Kaniko to push images:

1. Tekton reads the `docker-registry` type Secrets from the ServiceAccount
2. It creates a `~/.docker/config.json` file with the registry credentials
3. Build tools automatically read this config when pushing images

## Test with a simple Task

Let's verify the credentials are injected correctly:

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
        image: ubuntu
        script: |
          #!/usr/bin/env bash
          echo "=== Checking Git credentials ==="
          if [ -f /tekton/creds/.gitconfig ]; then
            echo "Git credentials found!"
            cat /tekton/creds/.gitconfig
          else
            echo "No Git credentials file (may be in legacy location)"
          fi
          echo ""
          echo "=== Checking Docker credentials ==="
          if [ -f /tekton/creds/.docker/config.json ]; then
            echo "Docker credentials found!"
          else
            echo "No Docker credentials file (may be in legacy location)"
          fi
          echo ""
          echo "Authentication setup verified!"
EOF
```

Check the logs:

```bash
tkn taskrun logs --last -f
```
