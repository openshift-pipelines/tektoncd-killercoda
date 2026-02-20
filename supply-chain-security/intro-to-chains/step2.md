# Run a TaskRun and see automatic signing

Now that Chains is configured with signing keys, let's run a simple Task and
see how Chains automatically signs the result.

## Create a simple Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello-chains
spec:
  steps:
    - name: hello
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        echo "Hello from Tekton Chains!"
        echo "This TaskRun will be automatically signed."
EOF
```

## Run the Task

```bash
tkn task start hello-chains --showlog
```

Wait for the TaskRun to complete. You should see the "Hello from Tekton
Chains!" message in the logs.

## Wait for Chains to sign

Chains watches for completed TaskRuns and signs them asynchronously. This
usually takes a few seconds:

```bash
sleep 10
```

## Check the signing annotation

Chains adds a `chains.tekton.dev/signed=true` annotation to every TaskRun it
signs. Let's check:

```bash
kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}'
```

You should see `true` -- this means Chains successfully signed the TaskRun.

## Inspect all Chains annotations

To see all the annotations Chains added:

```bash
TASKRUN_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "TaskRun: $TASKRUN_NAME"
kubectl get taskrun "$TASKRUN_NAME" -o jsonpath='{.metadata.annotations}' | python3 -m json.tool | grep chains
```

You should see several `chains.tekton.dev/*` annotations including the signed
status and the signature itself.

## How the signing flow works

1. You created and ran a TaskRun
2. The Chains controller detected the TaskRun completed
3. Chains generated a **SLSA provenance** document describing the TaskRun
4. Chains **signed** the provenance with the private key from `signing-secrets`
5. Chains stored the signature as an **annotation** on the TaskRun
6. Chains marked the TaskRun with `chains.tekton.dev/signed=true`

All of this happened automatically -- no manual intervention required.
