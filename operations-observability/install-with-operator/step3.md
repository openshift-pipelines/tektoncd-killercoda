# Configure Tekton via TektonConfig

Beyond choosing which components to install, TektonConfig lets you configure
Tekton Pipelines feature flags and settings. This replaces the need to manually
edit ConfigMaps in the `tekton-pipelines` namespace.

## View current pipeline configuration

Check the current pipeline configuration:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pipeline}' | python3 -m json.tool
```

This shows the Tekton Pipelines feature flags managed by the Operator.

## Enable a feature flag

Tekton Pipelines has several feature flags that control behavior. A commonly
used one is `enable-api-fields`, which controls access to alpha and beta
features.

Set `enable-api-fields` to `beta` to unlock beta-level features:

```bash
kubectl patch tektonconfig config --type merge \
  -p '{"spec":{"pipeline":{"enable-api-fields":"beta"}}}'
```

Verify the change:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pipeline.enable-api-fields}'
echo ""
```

You should see `beta`.

## Configure additional pipeline settings

You can also configure performance-related settings. For example, set the default
timeout for TaskRuns:

```bash
kubectl patch tektonconfig config --type merge \
  -p '{"spec":{"pipeline":{"default-timeout-minutes":"30"}}}'
```

Verify:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pipeline.default-timeout-minutes}'
echo ""
```

## How the Operator applies configuration

When you change settings in `spec.pipeline`, the Operator:

1. Detects the TektonConfig change
2. Updates the corresponding ConfigMap (`config-defaults`, `feature-flags`, etc.)
   in the `tekton-pipelines` namespace
3. The Tekton Pipelines controller picks up the ConfigMap changes

You can verify this by checking the ConfigMap directly:

```bash
kubectl get configmap feature-flags -n tekton-pipelines -o yaml | grep enable-api-fields
```

The value should match what you set in TektonConfig. The Operator keeps these
in sync -- if someone manually edits the ConfigMap, the Operator will revert it
to match the TektonConfig specification.

## View all configurable fields

To see all the fields you can configure under `spec.pipeline`, inspect the full
TektonConfig:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pipeline}' | python3 -m json.tool
```

Common configuration options include:

| Field | Description |
|-------|-------------|
| `enable-api-fields` | Enable alpha/beta API features |
| `default-timeout-minutes` | Default timeout for TaskRuns |
| `default-service-account` | Default service account for runs |
| `disable-affinity-assistant` | Disable affinity assistant for workspaces |

All of these can be set declaratively through TektonConfig, and the Operator
ensures they are applied consistently.
