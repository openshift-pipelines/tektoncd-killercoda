# Build and deploy the application

Now let's create Tasks for building a container image and deploying to
Kubernetes.

## Create a sample application

First, let's create a simple Nginx-based application that we'll build and
deploy:

```bash
mkdir -p /root/sample-app
```

```bash
cat <<'APPEOF' > /root/sample-app/Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
APPEOF
```

```bash
cat <<'APPEOF' > /root/sample-app/index.html
<!DOCTYPE html>
<html>
<head><title>Tekton Demo</title></head>
<body>
<h1>Hello from Tekton!</h1>
<p>This application was built and deployed by a Tekton Pipeline.</p>
</body>
</html>
APPEOF
```

```bash
cat <<'APPEOF' > /root/sample-app/kubernetes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: sample-app
          image: sample-app:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app
spec:
  selector:
    app: sample-app
  ports:
    - port: 80
      targetPort: 80
APPEOF
```

## Create a build Task

This Task uses [Kaniko](https://github.com/GoogleContainerTools/kaniko) to
build container images directly in the cluster without requiring Docker:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-image
spec:
  params:
    - name: image-name
      type: string
      description: Name for the built image
  workspaces:
    - name: source
      description: Source code workspace
  steps:
    - name: build
      image: gcr.io/kaniko-project/executor:latest
      args:
        - --dockerfile=\$(workspaces.source.path)/Dockerfile
        - --context=\$(workspaces.source.path)
        - --destination=\$(params.image-name)
        - --no-push
        - --tar-path=\$(workspaces.source.path)/image.tar
EOF
```

## Create a deploy Task

This Task applies Kubernetes manifests to deploy the application:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-app
spec:
  workspaces:
    - name: source
      description: Source code workspace with Kubernetes manifests
  params:
    - name: manifest
      type: string
      description: Path to the Kubernetes manifest
      default: kubernetes.yaml
  steps:
    - name: deploy
      image: bitnami/kubectl:latest
      script: |
        #!/bin/bash
        echo "Deploying application..."
        kubectl apply -f \$(workspaces.source.path)/\$(params.manifest)
        echo "Waiting for deployment to be ready..."
        kubectl rollout status deployment/sample-app --timeout=60s
        echo "Application deployed successfully!"
EOF
```

## Verify all Tasks

<!-- e2e-skip -->
```bash
tkn task list
```

You should see `git-clone`, `build-image`, and `deploy-app` listed.
