# Map Jenkins concepts to Tekton

Let's understand the conceptual mapping between Jenkins and Tekton.

## Concept mapping

```bash
echo "=== Jenkins to Tekton Concept Map ==="
echo ""
echo "Jenkins                  -> Tekton"
echo "─────────────────────────────────────────"
echo "Jenkinsfile              -> Pipeline YAML"
echo "Stage                    -> PipelineTask"
echo "Step                     -> Task Step"
echo "Agent / Node             -> Task image"
echo "Shared Library           -> StepAction / Catalog Task"
echo "Credentials              -> Kubernetes Secret"
echo "Jenkins Plugin           -> Tekton Task (from catalog)"
echo "Post { always {} }       -> Finally Tasks"
echo "Parallel stages          -> DAG (no runAfter)"
echo "Parameters               -> Pipeline params"
echo "When condition           -> When Expressions"
echo "Stash/unstash            -> Workspaces"
echo "Jenkins controller       -> Tekton Pipeline controller"
echo "Build history            -> Tekton Results"
```

## Create the Tekton equivalents

Let's create Tasks that mirror common Jenkins patterns:

```bash
cat <<TASKEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: checkout
  labels:
    migration: jenkins-to-tekton
spec:
  params:
    - name: repo
      type: string
      default: "https://github.com/example/app.git"
  steps:
    - name: clone
      image: alpine/git:2.43.0
      script: |
        #!/usr/bin/env sh
        echo "Jenkins equivalent: checkout scm"
        echo "Cloning: \$(params.repo)"
        # In real usage, use git-clone Task from catalog
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: maven-build
  labels:
    migration: jenkins-to-tekton
spec:
  steps:
    - name: build
      image: maven:3.9-eclipse-temurin-17
      script: |
        #!/usr/bin/env sh
        echo "Jenkins equivalent: sh 'mvn clean package'"
        echo "Running Maven build..."
        echo "Build successful!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: docker-build
  labels:
    migration: jenkins-to-tekton
spec:
  params:
    - name: image
      type: string
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Jenkins equivalent: docker.build(\$(params.image))"
        echo "Building image: \$(params.image)"
        echo "In Tekton, use Kaniko or Buildpacks instead of Docker"
TASKEOF

echo ""
echo "=== Migrated Tasks ==="
kubectl get task -l migration=jenkins-to-tekton
```

## Verify

```bash
kubectl get task checkout &>/dev/null && kubectl get task maven-build &>/dev/null
```
