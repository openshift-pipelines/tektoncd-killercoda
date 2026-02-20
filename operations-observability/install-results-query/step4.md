# Browse results with kubectl

In addition to the REST API, Tekton Results creates Kubernetes custom
resources that you can browse with `kubectl`. This makes it easy to
integrate Results into your existing Kubernetes workflows.

## List Result resources

```bash
kubectl get results.results.tekton.dev -n default
```

This shows all Result resources in the default namespace. Each Result
corresponds to a PipelineRun or TaskRun.

## Inspect a Result in detail

Pick one of the results and view its full YAML:

```bash
RESULT=$(kubectl get results.results.tekton.dev -n default -o jsonpath='{.items[0].metadata.name}')
kubectl get results.results.tekton.dev "${RESULT}" -n default -o yaml
```

Notice the annotations and status fields. These contain rich metadata about
the pipeline execution.

## List Records

Each Result has associated Records that contain the actual execution data:

```bash
kubectl get records.results.tekton.dev -n default
```

View a record in detail:

```bash
RECORD=$(kubectl get records.results.tekton.dev -n default -o jsonpath='{.items[0].metadata.name}')
kubectl get records.results.tekton.dev "${RECORD}" -n default -o yaml
```

## Historical analysis with kubectl

You can use standard `kubectl` flags to filter and sort results. For
example, to see results sorted by creation time:

```bash
kubectl get results.results.tekton.dev -n default --sort-by=.metadata.creationTimestamp
```

Count how many results have been captured:

```bash
echo "Total Results captured:"
kubectl get results.results.tekton.dev -n default --no-headers | wc -l
```

## The key takeaway

With Tekton Results installed:

1. **No code changes needed** - the watcher automatically captures every
   completed run
2. **Data survives pruning** - even if you delete PipelineRuns from the
   cluster, the data remains in PostgreSQL
3. **Two access methods** - use the REST API for programmatic access, or
   `kubectl` for ad-hoc browsing
4. **Filter and query** - the API supports CEL-based filtering for
   sophisticated queries

This makes Tekton Results essential for any production Tekton deployment
where audit trails and historical analysis matter.
