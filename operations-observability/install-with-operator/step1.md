# Explore the Operator and TektonConfig

When the Tekton Operator starts, it automatically creates a `TektonConfig`
resource named `config`. This resource is the central control point for your
entire Tekton installation.

## Check the Operator is running

First, verify the Tekton Operator pods are running:

```bash
kubectl get pods -n tekton-operator
```

You should see the `tekton-operator` and `tekton-operator-webhook` pods in a
`Running` state.

## Explore the TektonConfig resource

The Operator creates a `TektonConfig` object automatically. View it:

```bash
kubectl get tektonconfig
```

You should see a single resource named `config`. Now inspect its full
specification:

```bash
kubectl get tektonconfig config -o yaml
```

This is a large resource. The key sections are:

- **spec.profile** -- Which components to install (`all`, `lite`, or `basic`)
- **spec.targetNamespace** -- Where Tekton components are installed (default:
  `tekton-pipelines`)
- **spec.pipeline** -- Configuration for Tekton Pipelines
- **spec.trigger** -- Configuration for Tekton Triggers
- **spec.dashboard** -- Configuration for Tekton Dashboard

## Check which profile is active

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.profile}'
echo ""
```

The default profile is `all`, which installs all Tekton components: Pipelines,
Triggers, Dashboard, Results, and Chains.

## Understand the profiles

The Tekton Operator supports three profiles:

| Profile | Components |
|---------|-----------|
| **all** | Pipelines + Triggers + Dashboard + Results + Chains |
| **basic** | Pipelines + Triggers + Results + Chains (no Dashboard) |
| **lite** | Pipelines only |

## See installed components

Check what the Operator has installed:

```bash
kubectl get pods -n tekton-pipelines
```

With the `all` profile, you will see pods for Pipelines, Triggers, Dashboard,
Results, and Chains. The Operator manages the lifecycle of all these components
automatically.

## Check the TektonConfig status

The Operator reports installation status on the TektonConfig resource:

```bash
kubectl get tektonconfig config -o jsonpath='{.status.conditions}' | python3 -m json.tool
```

When all components are ready, you will see conditions with `status: "True"`.
