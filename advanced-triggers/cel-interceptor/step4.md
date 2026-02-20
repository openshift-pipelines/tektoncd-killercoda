# Combine filters and overlays for production patterns

In production, you typically combine **multiple filter conditions** with
**several overlays** to create a robust event-processing pipeline. Let's build
a production-like EventListener.

## Delete the old EventListener

```bash
kubectl delete eventlistener cel-demo
```

## Create a production-ready EventListener

This EventListener uses a compound CEL filter that:
- Only accepts push events (`body.action == 'push'`)
- Only triggers for the main branch (`body.ref == 'refs/heads/main'`)
- Ignores branch deletions (`body.deleted == false`)

It also uses overlays to compute deployment-ready values:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: cel-demo
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: production-trigger
      interceptors:
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.action == 'push' && body.ref == 'refs/heads/main' && body.deleted == false"
            - name: "overlays"
              value:
                - key: branch_name
                  expression: "body.ref.split('/')[2]"
                - key: short_sha
                  expression: "body.after.truncate(7)"
                - key: repo_url
                  expression: "body.repository.url"
                - key: deploy_env
                  expression: "body.ref == 'refs/heads/main' ? 'production' : 'staging'"
      bindings:
        - ref: production-binding
      template:
        ref: production-template
EOF
```

Notice the compound filter using `&&` (logical AND) and the `deploy_env` overlay
using a CEL ternary expression (`? :`) to compute the deployment environment
based on the branch.

## Create production TriggerBinding and TriggerTemplate

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: production-binding
spec:
  params:
    - name: repo-name
      value: $(body.repository.name)
    - name: branch-name
      value: $(extensions.branch_name)
    - name: short-sha
      value: $(extensions.short_sha)
    - name: repo-url
      value: $(extensions.repo_url)
    - name: deploy-env
      value: $(extensions.deploy_env)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: production-template
spec:
  params:
    - name: repo-name
    - name: branch-name
    - name: short-sha
    - name: repo-url
    - name: deploy-env
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: production-run-
      spec:
        pipelineRef:
          name: production-pipeline
        params:
          - name: repo-name
            value: $(tt.params.repo-name)
          - name: branch-name
            value: $(tt.params.branch-name)
          - name: short-sha
            value: $(tt.params.short-sha)
          - name: repo-url
            value: $(tt.params.repo-url)
          - name: deploy-env
            value: $(tt.params.deploy-env)
EOF
```

## Create the production Pipeline

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-info
spec:
  params:
    - name: repo-name
      type: string
    - name: branch-name
      type: string
    - name: short-sha
      type: string
    - name: repo-url
      type: string
    - name: deploy-env
      type: string
  steps:
    - name: log
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        echo "========================================="
        echo "  Production Deployment Triggered"
        echo "========================================="
        echo "Repository:  $(params.repo-name)"
        echo "Branch:      $(params.branch-name)"
        echo "Commit:      $(params.short-sha)"
        echo "Source:      $(params.repo-url)"
        echo "Environment: $(params.deploy-env)"
        echo "========================================="
        echo ""
        echo "In a real pipeline, this would:"
        echo "  1. Clone $(params.repo-url) at $(params.short-sha)"
        echo "  2. Build the application"
        echo "  3. Deploy to $(params.deploy-env)"
        echo "========================================="
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: production-pipeline
spec:
  params:
    - name: repo-name
      type: string
    - name: branch-name
      type: string
    - name: short-sha
      type: string
    - name: repo-url
      type: string
    - name: deploy-env
      type: string
  tasks:
    - name: deploy-info
      taskRef:
        name: deploy-info
      params:
        - name: repo-name
          value: $(params.repo-name)
        - name: branch-name
          value: $(params.branch-name)
        - name: short-sha
          value: $(params.short-sha)
        - name: repo-url
          value: $(params.repo-url)
        - name: deploy-env
          value: $(params.deploy-env)
EOF
```

## Test the production filter

```bash
kubectl wait --for=condition=ready eventlistener cel-demo --timeout=60s
sleep 2
pkill -f "port-forward.*el-cel-demo" 2>/dev/null || true
kubectl port-forward service/el-cel-demo 8080:8080 > /dev/null 2>&1 &
sleep 3
```

Send a push event to `main` (should trigger):

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "action": "push",
    "ref": "refs/heads/main",
    "deleted": false,
    "after": "f1a2b3c4d5e6f7890123456789abcdef01234567",
    "repository": {
      "name": "my-production-app",
      "url": "https://github.com/example/my-production-app"
    }
  }'
```

Wait and check:

```bash
sleep 8
tkn pipelinerun logs --last -f
```

You should see "Environment: production" and the other computed fields.

## Send a push to a feature branch (should be filtered out)

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "action": "push",
    "ref": "refs/heads/feature/new-feature",
    "deleted": false,
    "after": "9876543210abcdef9876543210abcdef98765432",
    "repository": {
      "name": "my-production-app",
      "url": "https://github.com/example/my-production-app"
    }
  }'
```

Check PipelineRun count -- the feature branch push should have been filtered:

```bash
sleep 5
kubectl get pipelinerun -l triggers.tekton.dev/eventlistener=cel-demo --no-headers 2>/dev/null | wc -l
```

Only the push to `main` should have created a PipelineRun. The feature branch
push was rejected by the compound filter because `body.ref` did not match
`refs/heads/main`.
