# Transform payloads with CEL overlays

Filtering is only half the story. CEL interceptors can also **transform** the
event payload by adding new fields computed from existing data. These new fields
are called **overlays**.

## Why overlays?

Webhook payloads often contain data in formats that are not directly useful:

- A Git ref like `refs/heads/main` when you need just `main`
- A full 40-character commit SHA when you need a short 7-character version
- Raw data that needs to be combined or reformatted

CEL overlays let you compute these values before they reach your TriggerBinding.

## Delete the old EventListener

```bash
kubectl delete eventlistener cel-demo
```

## Create an updated EventListener with overlays

This new EventListener adds **CEL overlays** that transform the payload:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: cel-demo
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: cel-overlay-trigger
      interceptors:
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.action == 'push'"
            - name: "overlays"
              value:
                - key: branch_name
                  expression: "body.ref.split('/')[2]"
                - key: short_sha
                  expression: "body.after.truncate(7)"
      bindings:
        - ref: cel-overlay-binding
      template:
        ref: cel-overlay-template
EOF
```

The overlays compute two new fields:
- **`branch_name`** -- extracts `main` from `refs/heads/main` using `split('/')`
- **`short_sha`** -- truncates the commit SHA to 7 characters using `truncate(7)`

These fields are added to `extensions` in the event payload and can be referenced
in TriggerBindings.

## Create updated TriggerBinding and TriggerTemplate

The TriggerBinding now uses the overlay fields via `$(extensions.*)`:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: cel-overlay-binding
spec:
  params:
    - name: action
      value: $(body.action)
    - name: repo-name
      value: $(body.repository.name)
    - name: branch-name
      value: $(extensions.branch_name)
    - name: short-sha
      value: $(extensions.short_sha)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: cel-overlay-template
spec:
  params:
    - name: action
    - name: repo-name
    - name: branch-name
    - name: short-sha
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: cel-overlay-run-
      spec:
        pipelineRef:
          name: overlay-pipeline
        params:
          - name: action
            value: $(tt.params.action)
          - name: repo-name
            value: $(tt.params.repo-name)
          - name: branch-name
            value: $(tt.params.branch-name)
          - name: short-sha
            value: $(tt.params.short-sha)
EOF
```

## Create the Pipeline that uses overlay fields

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: log-overlay
spec:
  params:
    - name: action
      type: string
    - name: repo-name
      type: string
    - name: branch-name
      type: string
    - name: short-sha
      type: string
  steps:
    - name: log
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "================================="
        echo "Event with CEL overlays!"
        echo "================================="
        echo "Action:      $(params.action)"
        echo "Repository:  $(params.repo-name)"
        echo "Branch:      $(params.branch-name)"
        echo "Short SHA:   $(params.short-sha)"
        echo "================================="
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: overlay-pipeline
spec:
  params:
    - name: action
      type: string
    - name: repo-name
      type: string
    - name: branch-name
      type: string
    - name: short-sha
      type: string
  tasks:
    - name: log-overlay
      taskRef:
        name: log-overlay
      params:
        - name: action
          value: $(params.action)
        - name: repo-name
          value: $(params.repo-name)
        - name: branch-name
          value: $(params.branch-name)
        - name: short-sha
          value: $(params.short-sha)
EOF
```

## Wait for the EventListener and send a test event

```bash
kubectl wait --for=condition=ready eventlistener cel-demo --timeout=60s
sleep 2
```

Kill the old port-forward and create a new one:

```bash
pkill -f "port-forward.*el-cel-demo" 2>/dev/null || true
kubectl port-forward service/el-cel-demo 8080:8080 > /dev/null 2>&1 &
sleep 3
```

Send an event with a full Git ref and commit SHA:

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "action": "push",
    "repository": {
      "name": "my-app",
      "url": "https://github.com/example/my-app"
    },
    "ref": "refs/heads/main",
    "after": "abc123def456789012345678901234567890abcd"
  }'
```

## View the transformed results

```bash
sleep 8
tkn pipelinerun logs --last -f
```

You should see:
- **Branch: main** (extracted from `refs/heads/main`)
- **Short SHA: abc123d** (truncated from the full SHA)

The CEL overlays transformed the raw webhook data into clean, usable values
before they reached the Pipeline.
