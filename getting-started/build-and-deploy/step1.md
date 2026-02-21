# Clone a Git repository with a Task

The first step in any CI/CD pipeline is getting the source code. The Tekton
community maintains a catalog of reusable Tasks at
[Artifact Hub](https://artifacthub.io/packages/search?org=tektoncd&sort=relevance&page=1). We'll use the **git-clone** Task.

## Install the git-clone Task

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
```

## Verify the Task was installed

<!-- e2e-skip -->
```bash
tkn task list
```

You should see `git-clone` listed.

## Test the git-clone Task

Let's test it by cloning a small sample repository. We'll use a Workspace to
store the cloned code:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: git-clone-test-
spec:
  taskRef:
    name: git-clone
  params:
    - name: url
      value: https://github.com/tektoncd/website
    - name: revision
      value: main
    - name: deleteExisting
      value: "true"
  workspaces:
    - name: output
      emptyDir: {}
EOF
```

## Check the logs

<!-- e2e-skip -->
```bash
tkn taskrun logs --last -f
```

You should see output showing the repository being cloned, including the commit
SHA and the number of files fetched.
