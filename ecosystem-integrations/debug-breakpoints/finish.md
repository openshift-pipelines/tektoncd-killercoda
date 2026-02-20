# Congratulations!

You have learned how to use Tekton's **breakpoint debug API** to interactively
debug failed Tasks.

## What you learned

- Enabling the **alpha breakpoint API** with `enable-api-fields: alpha`
- Setting **`onFailure` breakpoints** in the TaskRun spec
- **Exec into the paused container** to inspect files, env vars, and state
- Using **`/tekton/debug/continue`** and **`/tekton/debug/fail`** control files

## Key points to remember

- Breakpoints require `enable-api-fields: alpha` in feature-flags ConfigMap
- Add `debug: { breakpoints: { onFailure: "enabled" } }` to the TaskRun spec
- The pod pauses instead of terminating on step failure
- Use `kubectl exec` to enter the container and investigate
- Write to `/tekton/debug/continue` to resume, `/tekton/debug/fail` to abort
- Paused pods consume cluster resources -- do not use in production

## Real-world use cases

- **CI debugging**: Investigate why tests pass locally but fail in Tekton
- **Permission issues**: Check if secrets and volumes are mounted correctly
- **Network debugging**: Test connectivity from within the Task pod
- **Environment inspection**: Verify environment variables and file paths

## What's next

- [Debugging with tkn](https://killercoda.com/tekton/course/cli-mastery-catalog/debugging-with-tkn) - Debug using the tkn CLI
- [Retries and Timeouts](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/retries-timeouts) - Automated error handling
- [Debug documentation](https://tekton.dev/docs/pipelines/debug/) - Full breakpoint API reference
