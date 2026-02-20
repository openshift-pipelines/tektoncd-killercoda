# Congratulations!

You have learned how to use CEL Interceptors for event filtering and payload
transformation in Tekton Triggers!

## What you learned

- How to create an EventListener with a **CEL filter** expression
- How CEL filters **silently reject** non-matching events
- How to use **CEL overlays** to transform and enrich event payloads
- How to reference overlay fields via **`$(extensions.*)`** in TriggerBindings
- How to build **production patterns** with compound filters and computed fields

## CEL expression quick reference

| Expression | What it does |
|------------|-------------|
| `body.action == 'push'` | Match exact field value |
| `body.ref.split('/')[2]` | Split string and extract part |
| `body.after.truncate(7)` | Truncate string to N chars |
| `a && b` | Logical AND (both must be true) |
| `a \|\| b` | Logical OR (either can be true) |
| `condition ? a : b` | Ternary (if/else) |
| `body.ref.startsWith('refs/heads/')` | String prefix check |
| `has(body.pull_request)` | Check if field exists |

## Filter vs overlay

- **Filter** (`filter` param): Boolean expression. `true` = accept, `false` = reject.
- **Overlay** (`overlays` param): Computes new fields added to `extensions`. Does not filter.

Use filters to **decide whether to trigger**. Use overlays to **enrich the data** passed to Pipelines.

## What is next

- [GitHub Webhooks with Triggers](https://tekton.dev/docs/how-to-guides/connecting-github/) -
  Connect real GitHub webhooks to your EventListeners
- [Tekton Triggers documentation](https://tekton.dev/docs/triggers/) - Full
  reference for all interceptor types
- [CEL specification](https://github.com/google/cel-spec) - Complete CEL
  language reference
- [Interceptor Chaining](https://tekton.dev/docs/triggers/interceptors/) -
  Chain multiple interceptors (CEL, webhook, GitHub) together
