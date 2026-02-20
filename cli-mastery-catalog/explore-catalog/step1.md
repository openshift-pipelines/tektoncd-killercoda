# Browse the Tekton Catalog on Artifact Hub

The Tekton Catalog lives on GitHub at
[github.com/tektoncd/catalog](https://github.com/tektoncd/catalog) and is
indexed on **Artifact Hub**. In this step, you will install the popular
**git-clone** Task and explore its structure.

## Discover Tasks on Artifact Hub

Artifact Hub indexes Tekton Tasks at
[artifacthub.io/packages/search?kind=13](https://artifacthub.io/packages/search?kind=13).
You can search for Tasks by name, category, or keyword. The `git-clone` Task is
one of the most widely used catalog Tasks.

## Install the git-clone Task

Install the `git-clone` Task (version 0.9) directly from the Tekton Catalog
GitHub repository:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
```

## Verify the Task was installed

```bash
kubectl get task git-clone
```

You should see the `git-clone` Task listed.

## Inspect the Task with tkn

Use `tkn` to see the Task's parameters, workspaces, and results:

```bash
tkn task describe git-clone
```

Notice how the catalog Task follows conventions:

- **Parameters** have sensible defaults (e.g., `depth`, `subdirectory`)
- **Workspaces** use the standard `output` workspace for cloned source code
- **Results** emit useful data like `commit` SHA and `url`

## Examine the Task YAML

Look at the full YAML to understand the Task structure:

```bash
kubectl get task git-clone -o yaml | head -80
```

Key observations:

- The Task uses `apiVersion: tekton.dev/v1` (the stable API version)
- The main step uses a pinned image (`gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init`)
- Parameters are well-documented with descriptions

The git-clone Task is now installed and ready to use in Pipelines.
