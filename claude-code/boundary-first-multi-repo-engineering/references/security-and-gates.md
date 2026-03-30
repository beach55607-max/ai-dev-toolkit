# Security And Gates

Use this reference when the task touches backend routes, auth, automation that writes to durable systems, or cross-repo admin flows.

For the canonical list of protected surfaces, see `constitution.md`.

## Security-First Defaults

- Treat HMAC, auth headers, nonces, timestamps, secrets, env bindings, and replay protection as protected surfaces.
- Do not weaken auth just to make local testing easier.
- Do not replace a verified path with a temporary bypass unless the task explicitly asks for a migration and names the new guardrail.
- Keep secrets in environment-backed configuration, never in source constants.

## HMAC And Admin API Expectations

### `lg-proxy-worker`

- Read the local `AGENTS.md` first.
- If the task touches `/api/admin/*`, inspect: route definition, auth verifier, request headers, body hash or canonical string handling, D1/KV side effects.
- Preserve structured error behavior and avoid silent auth downgrades.

### `lg-s5-admin-hub`

- Treat GAS admin requests as the sender side of the same contract.
- When HMAC, request headers, or sync payloads change, inspect the worker receiver in the same turn.
- Preserve lock, backup, validation, and trace logging around sync and pull flows.

### `lg-linebot`

- Keep the existing HMAC protocol split intact when both user-sync and admin HMAC paths exist.
- Check whether the touched code uses the correct secret source and canonical format for that specific integration.

### `lg-acl-sync`

- Read the local `AGENTS.md` first.
- Treat whitelist sheet schema, trigger installers, PropertiesService keys, user-sync HMAC, admin HMAC, D1 health-check, and delete flows as protected surfaces.
- If the task touches sync users, store-list sync, pull-from-D1, or admin delete requests, inspect the worker consumer in the same turn.
- Preserve confirmation, rollback, and partial-failure messaging around destructive or durable admin actions.

### `lg-thinq-ext`

- Treat `manifest.json`, `permissions`, `host_permissions`, PAT handling, background network calls, and storage as protected surfaces.
- Keep external API auth flows inside the owning background path.
- Do not expand permissions or host origins casually.

## Mechanical Validation Defaults

### `lg-proxy-worker`

- Minimum for production-path work: `npm run gate:quick`
- Strong default for auth, routes, D1/KV, admin API, sync, rollback, or contract work: `npm run gate:pr`
- Do not stop at `npm run lint` or `npm run test` when gate commands exist.

### `lg-s5-admin-hub`

- Default: `npm run ci`
- Add narrower unit tests first when editing sync, pull, validator, or LLM admin flows.

### `lg-liff`

- Default path: lint + test + build
- Add GT or repo-specific verification when the local AGENTS or phase docs require it.

### `lg-linebot`

- Use repo-local lint and test commands plus any task-specific checks described in AGENTS or specs.

### `lg-thinq-ext`

- Default path: `npm run lint`, `npm run test`, `npm run build`
- Raise validation depth when changing manifest, permissions, background routing, storage, or auth flows.

### `lg-acl-sync`

- Default: `npm run ci`
- Add narrower unit tests first when editing HMAC helpers, whitelist readers, payload builders, trigger installers, or D1 health-check logic.
- Do not treat GAS-side write helpers or destructive cleanup flows as verified unless the related worker-side contract and rollback stance were also checked.

If a shared contract changed and only one side was validated, report the result as partial or blocked, not as passed.

## Reporting Rule

In the final summary, explicitly state:

- which auth or API surface was touched
- which gate or mechanical checks were run
- which checks were not run and why
- what rollback or blast-radius stance applies if durable state was affected
- what maker-checker evidence applies for D2/D3 work
