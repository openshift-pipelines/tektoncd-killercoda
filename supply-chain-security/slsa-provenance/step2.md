# Inspect the SLSA provenance attestation

Now that Chains has signed the TaskRun, let's extract the provenance
attestation and examine every field in the SLSA v1 format.

## Extract the provenance payload

The provenance is stored as a base64-encoded annotation on the TaskRun. Extract
and decode it:

```bash
TASKRUN_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "Inspecting TaskRun: $TASKRUN_NAME"
```

```bash
kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/payload-taskrun-$TASKRUN_NAME}" \
  | base64 -d | python3 -m json.tool > /tmp/provenance.json
```

## View the full provenance

```bash
cat /tmp/provenance.json
```

The output is a JSON document in the **in-toto attestation** format. Let's walk
through each section.

## Section 1: The in-toto envelope

The outermost structure follows the [in-toto attestation](https://in-toto.io/)
specification:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
print('_type:', data.get('_type', 'N/A'))
print('predicateType:', data.get('predicateType', 'N/A'))
"
```

- **`_type`**: `https://in-toto.io/Statement/v0.1` -- identifies this as an
  in-toto statement
- **`predicateType`**: `https://slsa.dev/provenance/v0.2` -- identifies the
  predicate as SLSA provenance

## Section 2: The subject

The `subject` field describes **what was built** -- the artifact(s) this
provenance applies to:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
print(json.dumps(data.get('subject', []), indent=2))
"
```

For TaskRun provenance, the subject is typically the TaskRun itself or any
images/artifacts it produced.

## Section 3: The predicate -- build metadata

The `predicate` section contains the actual SLSA provenance data. Let's examine
its top-level fields:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
pred = data.get('predicate', {})
print('buildType:', pred.get('buildType', 'N/A'))
print()
print('builder.id:', pred.get('builder', {}).get('id', 'N/A'))
print()
print('invocation keys:', list(pred.get('invocation', {}).keys()))
print()
print('buildConfig keys:', list(pred.get('buildConfig', {}).keys()))
print()
print('materials count:', len(pred.get('materials', [])))
"
```

Key fields explained:

- **`buildType`**: Identifies the build system (e.g., `tekton.dev/v1beta1/TaskRun`).
  This tells a verifier what kind of build produced the artifact.
- **`builder.id`**: Identifies the build platform.
- **`invocation`**: Contains the parameters and configuration used to start the build.
- **`buildConfig`**: Contains the actual build steps that were executed.
- **`materials`**: Lists the inputs to the build (source code, base images, etc.).

## Section 4: The invocation (build inputs)

The `invocation` section records how the build was triggered and what parameters
were provided:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
inv = data.get('predicate', {}).get('invocation', {})
print(json.dumps(inv, indent=2))
"
```

This captures the parameters you passed when starting the TaskRun, providing an
audit trail of exactly what inputs were used.

## Section 5: The buildConfig (build steps)

The `buildConfig` section records the actual Steps that were executed:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
bc = data.get('predicate', {}).get('buildConfig', {})
print(json.dumps(bc, indent=2)[:2000])
"
```

This includes the container images used for each Step, the entrypoint, and
arguments. This is critical for reproducibility -- anyone can see exactly what
commands were run.

## Section 6: Materials (build inputs)

The `materials` field lists all inputs to the build:

```bash
python3 -c "
import json
with open('/tmp/provenance.json') as f:
    data = json.load(f)
mats = data.get('predicate', {}).get('materials', [])
print(json.dumps(mats, indent=2))
"
```

Materials typically include the container images used in the Task Steps,
identified by their digest. This enables verification that the build used
trusted base images.

## Save the provenance for later

Save the provenance for use in the next step:

```bash
cp /tmp/provenance.json /root/provenance.json
echo "Provenance saved to /root/provenance.json"
```
