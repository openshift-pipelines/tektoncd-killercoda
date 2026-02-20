# Set up Chains and Kyverno

The install script has already deployed Tekton Chains and Kyverno. In this step,
you will configure Chains for image signing and verify that Kyverno is running.

## Configure Chains for image signing

Configure Chains with x509 signing and OCI storage:

```bash
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{
  "artifacts.oci.format": "simplesigning",
  "artifacts.oci.storage": "oci",
  "artifacts.oci.signer": "x509",
  "artifacts.taskrun.format": "slsa/v1",
  "artifacts.taskrun.storage": "oci",
  "artifacts.taskrun.signer": "x509"
}}'
```

## Generate cosign signing keys

```bash
COSIGN_PASSWORD="" cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

Press Enter when prompted for a password.

## Restart Chains

```bash
kubectl delete pod -l app.kubernetes.io/part-of=tekton-chains -n tekton-chains
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=60s
```

## Verify Kyverno is running

Check that Kyverno pods are ready:

```bash
kubectl get pods -n kyverno
```

You should see the Kyverno admission controller, background controller, cleanup
controller, and reports controller all running.

## Verify Kyverno webhook is registered

```bash
kubectl get validatingwebhookconfiguration | grep kyverno
kubectl get mutatingwebhookconfiguration | grep kyverno
```

Kyverno works as a Kubernetes **admission webhook** -- it intercepts API
requests (like creating Deployments) and evaluates them against policies before
allowing them.

## Create a deployment namespace

Create a separate namespace where you will deploy images. This is where the
Kyverno policy will be enforced:

```bash
kubectl create namespace secure-deployments
kubectl label namespace secure-deployments policy-enforced=true
```

The `policy-enforced=true` label will be used to scope the Kyverno policy so it
only applies to this namespace (leaving the system namespaces alone).

Both Chains and Kyverno are now configured and ready.
