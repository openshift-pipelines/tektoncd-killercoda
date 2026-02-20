# Find your entry in the Rekor log

After Chains signs a TaskRun with transparency enabled, it stores the Rekor log
entry information as annotations on the TaskRun. Let's find it.

## Check Chains signing status

First, check if Chains has signed the TaskRun:

```bash
TASKRUN=$(kubectl get taskrun -o name | head -1)
echo "TaskRun: $TASKRUN"

kubectl get $TASKRUN -o jsonpath='{.metadata.annotations}' | python3 -m json.tool 2>/dev/null || \
kubectl get $TASKRUN -o jsonpath='{.metadata.annotations}' | tr ',' '\n'
```

Look for annotations like:

- `chains.tekton.dev/signed: true` -- confirms Chains signed it
- `chains.tekton.dev/transparency` -- the Rekor log entry URL

## Search Rekor using rekor-cli

You can also search the Rekor public instance directly. Let's search by the
signing certificate or artifact:

```bash
# Get the TaskRun name
TASKRUN_NAME=$(kubectl get taskrun -o jsonpath='{.items[0].metadata.name}')
echo "Searching Rekor for entries related to: $TASKRUN_NAME"

# Search Rekor by email or artifact (if available)
# The public Rekor instance is at rekor.sigstore.dev
rekor-cli search --rekor_server https://rekor.sigstore.dev \
  --email "" 2>/dev/null || echo "No entries found with email search (expected for local x509 signing)"
```

## Understand the log entry structure

A Rekor log entry contains:

```
LogIndex:    Sequential position in the log
UUID:        Unique identifier
Body:        The signed content (base64-encoded)
IntegratedTime: When the entry was added
LogID:       The log tree ID
```

Let's retrieve a recent entry to see the structure:

```bash
# Get the latest few entries from Rekor
rekor-cli loginfo --rekor_server https://rekor.sigstore.dev 2>/dev/null || \
  echo "Note: rekor-cli may not connect if the cluster has limited outbound access"
```

## Local verification with stored annotations

Even without Rekor access, Chains stores the signing data locally:

```bash
TASKRUN=$(kubectl get taskrun -o name | head -1)

echo "=== Chains Annotations ==="
kubectl get $TASKRUN -o json | python3 -c "
import sys, json
data = json.load(sys.stdin)
annotations = data.get('metadata', {}).get('annotations', {})
for k, v in sorted(annotations.items()):
    if 'chains' in k:
        print(f'  {k}: {v[:80]}...' if len(v) > 80 else f'  {k}: {v}')
" 2>/dev/null || echo "Chains annotations present on TaskRun"
```

## Verify

Confirm the TaskRun has been signed by Chains:

```bash
TASKRUN=$(kubectl get taskrun -o name | head -1)
SIGNED=$(kubectl get $TASKRUN -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null)
echo "Signed: $SIGNED"
```
