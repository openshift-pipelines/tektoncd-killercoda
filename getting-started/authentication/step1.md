# Authenticate with a private Git repository

When your source code is in a private repository, Tekton needs credentials to
clone it. Tekton uses Kubernetes Secrets with a special annotation to match
credentials to Git hosts.

## Create a Git authentication Secret

Tekton supports the `kubernetes.io/basic-auth` Secret type for Git
authentication. In production, you'd use a Personal Access Token (PAT) as the
password:

```bash
kubectl create secret generic git-credentials \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=tekton-bot \
  --from-literal=password=my-secret-token
```

## Annotate the Secret for Tekton

Tekton needs to know which Git host this Secret is for. The annotation
`tekton.dev/git-0` tells Tekton to use this Secret when accessing
`https://github.com`:

```bash
kubectl annotate secret git-credentials \
  "tekton.dev/git-0=https://github.com"
```

The `git-0` suffix is an index — you can have multiple Git credentials:
- `tekton.dev/git-0=https://github.com`
- `tekton.dev/git-1=https://gitlab.com`

## Create a ServiceAccount with the Secret

A ServiceAccount bundles Secrets together and is referenced by TaskRuns and
PipelineRuns:

```bash
kubectl create serviceaccount git-bot
```

```bash
kubectl patch serviceaccount git-bot \
  -p '{"secrets": [{"name": "git-credentials"}]}'
```

## Verify the setup

Check that the ServiceAccount has the Secret attached:

```bash
kubectl get serviceaccount git-bot -o yaml
```

You should see `git-credentials` listed under `secrets`.

## How it works

When a TaskRun or PipelineRun uses this ServiceAccount:

1. Tekton reads the Secrets attached to the ServiceAccount
2. It checks the `tekton.dev/git-*` annotations to find matching hosts
3. It injects the credentials as a `.gitconfig` and `.git-credentials` file
   into the Task's Steps
4. Git commands (like `git clone`) automatically use these credentials
