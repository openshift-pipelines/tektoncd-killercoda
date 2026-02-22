# Production pattern: validate, filter, transform, enrich

In this step, you will build a production-grade 3-interceptor chain that
demonstrates progressive event body modification. Each interceptor builds on
the output of the previous one, and the final TriggerBinding reads fields that
were added by the interceptors.

## Create a Pipeline for the production pattern

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: production-event-pipeline
spec:
  params:
    - name: repo-name
      type: string
    - name: branch
      type: string
    - name: deploy-env
      type: string
    - name: priority
      type: string
  tasks:
    - name: process-event
      taskRef:
        name: print-event-info
      params:
        - name: event-type
          value: "deploy to $(params.deploy-env)"
        - name: repo-name
          value: "$(params.repo-name) ($(params.branch))"
        - name: timestamp
          value: "priority=$(params.priority)"
EOF
```

## Create TriggerBinding and TriggerTemplate

The TriggerBinding reads fields from the original payload AND from fields added
by the CEL overlays:

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
    - name: branch
      value: $(body.branch_name)
    - name: deploy-env
      value: $(body.deploy_environment)
    - name: priority
      value: $(body.priority_level)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: production-template
spec:
  params:
    - name: repo-name
    - name: branch
    - name: deploy-env
    - name: priority
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: production-run-
      spec:
        pipelineRef:
          name: production-event-pipeline
        params:
          - name: repo-name
            value: $(tt.params.repo-name)
          - name: branch
            value: $(tt.params.branch)
          - name: deploy-env
            value: $(tt.params.deploy-env)
          - name: priority
            value: $(tt.params.priority)
EOF
```

## Create the 3-interceptor chain EventListener

This is the production pattern with **three interceptors** that progressively
modify the event body:

1. **Filter**: Only accept push events with a non-empty repository name
2. **Transform**: Extract the branch name from `refs/heads/...` and determine
   the deploy environment based on the branch
3. **Enrich**: Add a priority level based on the deploy environment

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: production-chain
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: production-trigger
      interceptors:
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.event_type == 'push' && has(body.repository) && body.repository.name != ''"
        - ref:
            name: "cel"
          params:
            - name: "overlays"
              value:
                - key: branch_name
                  expression: "body.ref.split('/')[2]"
                - key: deploy_environment
                  expression: "body.ref.endsWith('main') ? 'production' : (body.ref.endsWith('staging') ? 'staging' : 'development')"
        - ref:
            name: "cel"
          params:
            - name: "overlays"
              value:
                - key: priority_level
                  expression: "body.deploy_environment == 'production' ? 'high' : (body.deploy_environment == 'staging' ? 'medium' : 'low')"
      bindings:
        - ref: production-binding
      template:
        ref: production-template
EOF
```

## Wait for the EventListener

```bash
kubectl wait --for=condition=ready eventlistener production-chain --timeout=60s
kubectl get service el-production-chain
```

## Understand the progressive modification

Let's trace what happens to the event body through each interceptor:

```
Original event body:
  { "event_type": "push", "ref": "refs/heads/main", "repository": { "name": "my-app" } }

After Interceptor 1 (filter):
  (unchanged -- filter only passes/rejects, does not modify)

After Interceptor 2 (transform overlays):
  + "branch_name": "main"
  + "deploy_environment": "production"

After Interceptor 3 (enrich overlay):
  + "priority_level": "high"   (because deploy_environment == "production")
```

The TriggerBinding can now read `branch_name`, `deploy_environment`, and
`priority_level` - fields that did not exist in the original webhook payload.

## Test: push to main (production, high priority)

```bash
curl -X POST http://$(kubectl get service el-production-chain -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "push",
    "ref": "refs/heads/main",
    "repository": {"name": "my-app"},
    "head_commit": {"id": "abc123"}
  }'
```

```bash
sleep 3
tkn pipelinerun list | grep production-run || true
```

## Test: push to staging (staging, medium priority)

```bash
curl -X POST http://$(kubectl get service el-production-chain -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "push",
    "ref": "refs/heads/staging",
    "repository": {"name": "my-app"},
    "head_commit": {"id": "def456"}
  }'
```

```bash
sleep 3
tkn pipelinerun list | grep production-run || true
```

## Test: push to a feature branch (development, low priority)

```bash
curl -X POST http://$(kubectl get service el-production-chain -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "push",
    "ref": "refs/heads/feature/new-ui",
    "repository": {"name": "my-app"},
    "head_commit": {"id": "ghi789"}
  }'
```

```bash
sleep 3
tkn pipelinerun list | grep production-run || true
```

You should now see three PipelineRuns, one for each branch. Each one received
the correct `deploy_environment` and `priority_level` values computed by the
interceptor chain.

## Check the Pipeline logs

View the logs to confirm the computed values were passed through:

<!-- e2e-skip -->
```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
tkn pipelinerun logs "$PR_NAME" -f
```

The interceptor chain computed `deploy_environment` and `priority_level` from
the branch name, and these computed values were passed all the way through to
the Pipeline as parameters.
