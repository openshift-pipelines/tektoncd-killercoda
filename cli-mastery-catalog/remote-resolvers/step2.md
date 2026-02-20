# Use the Git Resolver to fetch from a Git repository

The **Git Resolver** fetches Task and Pipeline definitions directly from a Git
repository. This is ideal for referencing Tasks stored in private repositories,
internal catalogs, or any Git-hosted YAML file. You specify the repository URL,
branch or tag, and the file path within the repo.

## Create a TaskRun with the Git Resolver

Create a TaskRun that fetches a `curl` task from the tektoncd/catalog GitHub
repository and uses it to check the HTTP status code of a URL:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: git-resolver-demo
  labels:
    tutorial: remote-resolvers
spec:
  taskRef:
    resolver: git
    params:
      - name: url
        value: "https://github.com/tektoncd/catalog.git"
      - name: pathInRepo
        value: "task/curl/0.1/curl.yaml"
      - name: revision
        value: "main"
  params:
    - name: url
      value: "https://tekton.dev"
    - name: options
      type: array
      value:
        - "-s"
        - "-o"
        - "/dev/null"
        - "-w"
        - "%{http_code}"
EOF
```

There are three key resolver parameters to understand:

1. **`url`** (in the resolver params) -- The Git repository URL. This can be any
   public or private Git repository. For private repos, you would configure
   authentication via a Kubernetes Secret.
2. **`revision`** -- The Git branch, tag, or commit SHA to use. Using a tag or
   SHA ensures reproducible builds; using a branch name like `main` always
   fetches the latest version.
3. **`pathInRepo`** -- The file path within the repository that contains the
   Task or Pipeline YAML definition.

The TaskRun also passes runtime parameters (`url` and `options`) to the resolved
`curl` task, which will check the HTTP status code of `https://tekton.dev`.

## Watch the TaskRun

Wait for the TaskRun to complete and view the logs:

```bash
kubectl wait --for=condition=Succeeded=False --for=condition=Succeeded=True \
  taskrun/git-resolver-demo --timeout=120s 2>/dev/null || true
```

```bash
tkn taskrun logs git-resolver-demo
```

You should see the HTTP status code (likely `200` or `301`) returned by the curl
command.

## Inspect the resolved reference

Check the TaskRun details to confirm the Task was resolved from Git:

```bash
tkn taskrun describe git-resolver-demo
```

## When to use the Git Resolver

The Git Resolver is especially useful when:

- Your organization maintains an **internal catalog** of Tasks in a private Git
  repository
- You want to reference a Task from a **specific commit or tag** for
  reproducibility
- You need to fetch Tasks from repositories that are **not published** to
  Artifact Hub
- You want to test a Task definition from a **feature branch** before merging
