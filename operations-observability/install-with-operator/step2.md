# Manage component versions and profiles

One of the Operator's most powerful features is the ability to change your Tekton
installation by simply editing the TektonConfig resource. The Operator watches
for changes and reconciles the cluster state accordingly.

## Switch to the lite profile

The `lite` profile installs Pipelines and Triggers but not the Dashboard. This
is useful for CI/CD-focused clusters where a web UI is not needed.

Change the profile:

```bash
kubectl patch tektonconfig config --type merge -p '{"spec":{"profile":"lite"}}'
```

Watch the Operator reconcile. It will remove the Dashboard components:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.profile}'
echo ""
```

You should see `lite`. Wait a moment for the Operator to reconcile:

```bash
sleep 15
```

## Verify the profile change

Check the pods in the `tekton-pipelines` namespace. Dashboard pods should be
gone or terminating:

```bash
kubectl get pods -n tekton-pipelines
```

With the `lite` profile, you should see only Pipelines and Triggers pods.

## Switch to the basic profile

The `basic` profile installs only Tekton Pipelines -- the minimum needed to run
Tasks and Pipelines:

```bash
kubectl patch tektonconfig config --type merge -p '{"spec":{"profile":"basic"}}'
```

Wait for reconciliation:

```bash
sleep 15
kubectl get tektonconfig config -o jsonpath='{.spec.profile}'
echo ""
```

## Switch back to the all profile

For the rest of this tutorial, switch back to the `all` profile:

```bash
kubectl patch tektonconfig config --type merge -p '{"spec":{"profile":"all"}}'
```

Wait for all components to come back:

```bash
sleep 20
kubectl get pods -n tekton-pipelines
```

## Understanding Operator reconciliation

The key takeaway is that the Operator continuously reconciles the cluster state
to match the TektonConfig specification. When you change the profile:

1. The Operator detects the change to the TektonConfig resource
2. It calculates what components need to be added or removed
3. It applies the necessary Kubernetes resources
4. It reports the status back on the TektonConfig resource

This is the declarative model -- you declare what you want, and the Operator
makes it happen. You never need to manually apply or delete individual component
YAMLs.
