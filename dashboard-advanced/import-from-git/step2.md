# Import Tasks from a Git repository

Let's simulate the import flow by creating Tekton resources from a Git-hosted
YAML file.

## Create a local Git repo with Tekton resources

Since the Killercoda environment may not have outbound Git access to all repos,
let's create a local repository to demonstrate the pattern:

```bash
mkdir -p /tmp/tekton-repo/tasks

cat <<EOF > /tmp/tekton-repo/tasks/greeting-task.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: greeting
  labels:
    source: git-import
spec:
  params:
    - name: name
      type: string
      default: "World"
  steps:
    - name: greet
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Hello, \$(params.name)!"
EOF

cat <<EOF > /tmp/tekton-repo/tasks/timestamp-task.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: timestamp
  labels:
    source: git-import
spec:
  results:
    - name: current-time
      type: string
  steps:
    - name: stamp
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo -n "\$(date -u +%Y-%m-%dT%H:%M:%SZ)" > \$(results.current-time.path)
        echo "Timestamp: \$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

echo "Created local repo with 2 Task YAML files"
```

## Apply the Tasks (simulating Dashboard import)

The Dashboard Import feature essentially does `kubectl apply` on YAML files
found in a Git repository. Let's do the same:

```bash
kubectl apply -f /tmp/tekton-repo/tasks/
echo ""
echo "=== Imported Tasks ==="
kubectl get task -l source=git-import
```

## Verify

Confirm the imported Tasks exist:

```bash
kubectl get task greeting &>/dev/null && kubectl get task timestamp &>/dev/null
```
