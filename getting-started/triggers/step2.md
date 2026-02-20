# Set up Tekton Triggers

Now let's create the Trigger components that will listen for events and
automatically create PipelineRuns.

## Create a ServiceAccount for the EventListener

The EventListener needs permissions to create PipelineRuns:

```bash
kubectl create serviceaccount tekton-triggers-sa
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-binding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-clusterbinding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
EOF
```

## Create a TriggerBinding

A **TriggerBinding** extracts values from the event payload. This one extracts
fields from a GitHub-style push event:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
spec:
  params:
    - name: git-repo-url
      value: \$(body.repository.url)
    - name: git-commit-sha
      value: \$(body.head_commit.id)
    - name: git-commit-message
      value: \$(body.head_commit.message)
EOF
```

The `$(body.*)` expressions extract values from the JSON event payload.

## Create a TriggerTemplate

A **TriggerTemplate** defines what to create when an event is received. This
one creates a PipelineRun:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-push-template
spec:
  params:
    - name: git-repo-url
    - name: git-commit-sha
    - name: git-commit-message
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: ci-pipeline-run-
      spec:
        pipelineRef:
          name: ci-pipeline
        params:
          - name: git-repo-url
            value: \$(tt.params.git-repo-url)
          - name: git-commit-sha
            value: \$(tt.params.git-commit-sha)
          - name: git-commit-message
            value: \$(tt.params.git-commit-message)
EOF
```

## Create an EventListener

An **EventListener** is a Kubernetes Service that receives events and connects
the TriggerBinding (which extracts data) to the TriggerTemplate (which creates
resources):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-push
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
EOF
```

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=ready eventlistener github-listener --timeout=60s
```

The EventListener creates a Service that listens on port 8080. Verify it:

```bash
kubectl get service el-github-listener
```
