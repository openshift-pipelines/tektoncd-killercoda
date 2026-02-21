# Convert a Jenkinsfile to a Tekton Pipeline

Let's take a real Jenkinsfile and convert it step by step.

## The original Jenkinsfile

```bash
echo "=== Original Jenkinsfile ==="
cat << 'JENKINSFILE'
pipeline {
    agent any
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0')
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps { sh 'mvn test' }
                }
                stage('Lint') {
                    steps { sh 'mvn checkstyle:check' }
                }
            }
        }
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh "kubectl apply -f k8s/"
            }
        }
    }
    post {
        always { sh 'echo Cleanup' }
    }
}
JENKINSFILE
```

## The Tekton equivalent

```bash
cat <<PIPEEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: unit-tests
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Jenkins: sh 'mvn test'"
        echo "Running unit tests... passed!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: lint-check
spec:
  steps:
    - name: lint
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Jenkins: sh 'mvn checkstyle:check'"
        echo "Lint check... passed!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-app
spec:
  params:
    - name: version
      type: string
  steps:
    - name: deploy
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Jenkins: sh 'kubectl apply -f k8s/'"
        echo "Deploying version: \$(params.version)"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: cleanup
spec:
  steps:
    - name: cleanup
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Jenkins: post { always { sh 'echo Cleanup' } }"
        echo "Cleanup complete!"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: migrated-pipeline
spec:
  params:
    - name: version
      type: string
      default: "1.0.0"
  tasks:
    - name: build
      taskRef:
        name: maven-build
    - name: unit-tests
      runAfter: [build]
      taskRef:
        name: unit-tests
    - name: lint
      runAfter: [build]
      taskRef:
        name: lint-check
    - name: deploy
      runAfter: [unit-tests, lint]
      taskRef:
        name: deploy-app
      params:
        - name: version
          value: "\$(params.version)"
  finally:
    - name: cleanup
      taskRef:
        name: cleanup
PIPEEOF

echo ""
echo "=== Key Conversions ==="
echo "  parallel stages -> Tasks without shared runAfter (unit-tests + lint)"
echo "  post { always } -> finally tasks"
echo "  parameters      -> Pipeline params"
echo "  when { branch }  -> When Expressions (not shown for simplicity)"
```

## Run the migrated Pipeline

```bash
tkn pipeline start migrated-pipeline -p version="2.0.0" --showlog
```

## Verify

```bash
kubectl get pipeline migrated-pipeline &>/dev/null
```
