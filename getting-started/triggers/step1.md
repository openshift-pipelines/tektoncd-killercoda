# Create a Pipeline to trigger

Before setting up Triggers, we need a Pipeline that will be triggered by events.
Let's create a simple Pipeline that logs information about a Git commit.

## Create the Tasks

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: log-commit
spec:
  params:
    - name: commit-sha
      type: string
      description: The Git commit SHA
    - name: commit-message
      type: string
      description: The commit message
    - name: repository-url
      type: string
      description: The Git repository URL
  steps:
    - name: log
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "========================================="
        echo "New commit detected!"
        echo "========================================="
        echo "Repository: \$(params.repository-url)"
        echo "Commit SHA: \$(params.commit-sha)"
        echo "Message:    \$(params.commit-message)"
        echo "========================================="
EOF
```

## Create the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: ci-pipeline
spec:
  params:
    - name: git-repo-url
      type: string
    - name: git-commit-sha
      type: string
    - name: git-commit-message
      type: string
  tasks:
    - name: log-commit
      taskRef:
        name: log-commit
      params:
        - name: repository-url
          value: \$(params.git-repo-url)
        - name: commit-sha
          value: \$(params.git-commit-sha)
        - name: commit-message
          value: \$(params.git-commit-message)
EOF
```

## Verify the Pipeline

<!-- e2e-skip -->
```bash
tkn pipeline list
```

You should see `ci-pipeline` listed.
