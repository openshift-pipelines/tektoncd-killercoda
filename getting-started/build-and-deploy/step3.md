# Create the CI/CD Pipeline

Now let's put it all together into a Pipeline that builds and deploys our
sample application.

## Copy the sample app to a PersistentVolume

Since we're using a local sample app (not cloning from Git), let's create a
PVC and copy our files into it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: source-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

Copy the sample app files into the PVC:

```bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: copy-files
spec:
  restartPolicy: Never
  volumes:
    - name: source
      persistentVolumeClaim:
        claimName: source-pvc
  containers:
    - name: copy
      image: ubuntu
      command: ["sh", "-c", "cp /input/* /workspace/ && ls -la /workspace/ && sleep 5"]
      volumeMounts:
        - name: source
          mountPath: /workspace
      env: []
EOF
```

Wait for the copy pod to start, then copy files:

```bash
kubectl wait --for=condition=Ready pod/copy-files --timeout=30s
kubectl cp /root/sample-app/Dockerfile copy-files:/workspace/Dockerfile
kubectl cp /root/sample-app/index.html copy-files:/workspace/index.html
kubectl cp /root/sample-app/kubernetes.yaml copy-files:/workspace/kubernetes.yaml
kubectl delete pod copy-files
```

## Create the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  workspaces:
    - name: shared-workspace
  tasks:
    - name: build
      taskRef:
        name: build-image
      params:
        - name: image-name
          value: sample-app:latest
      workspaces:
        - name: source
          workspace: shared-workspace
    - name: deploy
      runAfter:
        - build
      taskRef:
        name: deploy-app
      workspaces:
        - name: source
          workspace: shared-workspace
EOF
```

## Run the Pipeline

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: build-and-deploy-run-
spec:
  pipelineRef:
    name: build-and-deploy
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: source-pvc
EOF
```

## Monitor the Pipeline

```bash
tkn pipelinerun logs --last -f
```

You should see the build Task running Kaniko to build the container image,
followed by the deploy Task applying the Kubernetes manifests.

## Verify the deployment

Once the PipelineRun completes, check that the application is deployed:

```bash
kubectl get deployment sample-app
kubectl get service sample-app
```

You can also check the running pods:

```bash
kubectl get pods -l app=sample-app
```

The application is deployed and running in the cluster, built entirely by your
Tekton Pipeline!
