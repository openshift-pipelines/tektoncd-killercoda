# Authenticate with a private Git repository

When your source code is in a private repository, Tekton needs credentials to
clone it. Tekton uses Kubernetes Secrets with a special annotation to match
credentials to Git hosts.

## Supported Secret types for Git

Tekton supports two Secret types for Git authentication:

| Secret Type | Use Case |
|-------------|----------|
| `kubernetes.io/basic-auth` | Username + password/token (HTTPS) |
| `kubernetes.io/ssh-auth` | SSH private key |

## Create a basic-auth Secret for Git

In production, you'd use a Personal Access Token (PAT) as the password.
The `tekton.dev/git-0` annotation tells Tekton which host this Secret applies
to:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: tekton-bot
  password: my-secret-token
EOF
```

The `git-0` suffix is an index — you can add multiple Git credentials on a
single Secret:

- `tekton.dev/git-0: https://github.com`
- `tekton.dev/git-1: https://gitlab.com`

## Create a ServiceAccount with the Secret

A ServiceAccount bundles Secrets together and is referenced by TaskRuns and
PipelineRuns:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: git-bot
secrets:
  - name: git-credentials
EOF
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
3. It creates a `~/.gitconfig` file and `~/.git-credentials` file in the
   Step's container
4. Git commands (like `git clone`) automatically use these credentials

The generated files look like:

```
# ~/.gitconfig
[credential]
    helper = store
[credential "https://github.com"]
    username = "tekton-bot"

# ~/.git-credentials
https://tekton-bot:my-secret-token@github.com
```
