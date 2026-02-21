# Analyze Pipeline performance with traces

Traces give you deep insight into Pipeline execution. Let's learn how to
use Jaeger to analyze performance.

## Run a second Pipeline for comparison

```bash
tkn pipeline start traced-pipeline --showlog
```

## Understanding the trace structure

```bash
echo "=== Trace Span Hierarchy ==="
echo ""
echo "PipelineRun (root span)"
echo "  |-- TaskRun: clone (3s)"
echo "  |     |-- Step: clone"
echo "  |-- TaskRun: lint (2s)        <-- parallel"
echo "  |     |-- Step: lint"
echo "  |-- TaskRun: unit-test (4s)   <-- parallel"
echo "  |     |-- Step: test"
echo "  |-- TaskRun: build (5s)"
echo "        |-- Step: build"
echo ""
echo "Key observations from the trace:"
echo "  - Total wall time: ~12s (not 14s, because lint+test run in parallel)"
echo "  - Scheduling overhead: visible as gaps between spans"
echo "  - Critical path: clone -> unit-test -> build (12s)"
echo "  - Non-critical: lint finishes before unit-test"
```

## Analyze with Jaeger UI features

```bash
echo "=== Jaeger UI Analysis Features ==="
echo ""
echo "1. TRACE COMPARISON"
echo "   Select two traces and compare side-by-side."
echo "   Useful for detecting performance regressions."
echo ""
echo "2. SPAN DETAILS"
echo "   Click any span to see:"
echo "   - Tags (TaskRun name, step name, status)"
echo "   - Duration breakdown"
echo "   - Logs (if configured)"
echo ""
echo "3. SERVICE GRAPH"
echo "   Shows dependencies between services."
echo "   For Tekton: controller -> TaskRun pods"
echo ""
echo "4. SEARCH"
echo "   Filter traces by:"
echo "   - Service: tekton-pipelines-controller"
echo "   - Duration: min/max"
echo "   - Tags: specific PipelineRun names"
```

## Performance analysis tips

```bash
echo "=== Common Bottleneck Patterns ==="
echo ""
echo "1. Image pull overhead:"
echo "   Large gaps at the start of TaskRun spans"
echo "   Fix: Use imagePullPolicy: IfNotPresent, pre-pull images"
echo ""
echo "2. Sequential bottleneck:"
echo "   All Tasks run in series (no parallel spans)"
echo "   Fix: Use DAG dependencies (runAfter) to parallelize"
echo ""
echo "3. Slow step in critical path:"
echo "   One step takes 80% of the total time"
echo "   Fix: Optimize that step or split into parallel Tasks"
echo ""
echo "4. Scheduling overhead:"
echo "   Large gaps between Task spans (pod scheduling)"
echo "   Fix: Use node affinity, pod priority, or resource requests"
```

## Verify

Confirm multiple PipelineRuns have been traced:

```bash
COUNT=$(kubectl get pipelinerun -l tekton.dev/pipeline=traced-pipeline -o name | wc -l | tr -d ' ')
echo "Traced PipelineRuns: $COUNT"
[ "$COUNT" -ge 2 ]
```
