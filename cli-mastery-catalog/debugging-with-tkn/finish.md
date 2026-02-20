# Congratulations!

You have learned how to debug failed Tekton Pipelines using the `tkn` CLI and
`kubectl`.

## What you learned

- **Creating failure scenarios** -- how different types of errors (image pull
  failures, script errors) manifest in Tekton
- **tkn pipelinerun describe** -- getting a high-level overview of Pipeline
  success and failure
- **tkn taskrun describe and logs** -- drilling down into individual Task
  failures to read error messages
- **kubectl describe pod** -- using Kubernetes-level debugging for image pull
  errors and other pod-level issues
- **tkn pipeline start --last** -- quickly rerunning a Pipeline after fixing
  issues
- **tkn pipelinerun cancel** -- stopping a running Pipeline immediately

## The debugging flow

```
tkn pipelinerun describe  -->  tkn taskrun list
       |                              |
       v                              v
  Identify failed Tasks      tkn taskrun describe / logs
                                      |
                                      v
                              kubectl describe pod
                                      |
                                      v
                                Fix and rerun
```

## Next steps

- [tkn CLI Reference](https://tekton.dev/docs/cli/) -- Full tkn CLI documentation
- [Debugging Pipelines](https://tekton.dev/docs/pipelines/pipelines/#debugging) -- Official debugging guide
- [Tekton documentation](https://tekton.dev/docs/) -- Full documentation for all Tekton components
