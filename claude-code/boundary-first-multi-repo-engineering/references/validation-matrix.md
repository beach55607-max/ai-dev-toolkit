# Validation Matrix

Use this reference after the edit path is clear.

## Validation Order

1. Run the narrowest relevant test first.
2. Run repo-standard lint and test commands.
3. Run the stronger gate command when the repo defines one and the change affects production paths.

Do not stop at lint or unit tests alone when the repo already defines a gate that bundles guards, contract checks, or build verification.

If a shared contract changes, one-side-only validation is partial evidence, not a pass. Report it as partial or blocked in close-out.

## Repo Commands

### `lg-proxy-worker`

- Fast check: `npm run gate:quick`
- Full gate: `npm run gate:pr`
- Standard lint: `npm run lint`
- Standard test: `npm run test`

Use the full gate when changing: `src/`, guard-sensitive contracts, route dispatch, D1/KV logic, shared backend config, HMAC, auth, admin API, sync, rollback, or durable write paths.

### `lg-s5-admin-hub`

- Standard CI bundle: `npm run ci`
- Individual: `npm run lint`, `npm run test`, `npm run lint:dup`

Prioritize unit tests when changing schema validation, sync/pull behavior, or LLM review/promote helpers.

### `lg-liff`

- Standard lint: `npm run lint`
- Standard test: `npm run test`
- Build check: `npm run build`

Prefer reading the repo AGENTS and GT docs to decide whether GT runner or build verification is also expected.

### `lg-linebot`

- Start with repo-local lint and test commands from `package.json` and `AGENTS.md`.
- When the task touches GAS sync or HMAC flows, verify the nearest unit tests and any repo-documented CI bundle.

### `lg-acl-sync`

- Standard CI bundle: `npm run ci`
- Standard lint: `npm run lint`
- Standard test: `npm run test`

Raise validation depth when changing whitelist sheet schema, trigger installers, HMAC helpers, admin delete flows, D1 pull/sync semantics, PropertiesService-backed config keys, or any GAS-to-worker contract.

### `lg-thinq-ext`

- Standard lint: `npm run lint`
- Standard test: `npm run test`
- Build check: `npm run build`

Raise validation depth when changing `manifest.json`, permissions, `host_permissions`, background polling/messaging/auth flows, extension storage schema, or popup/options contracts.

## When Validation Is Blocked

State exactly which command was skipped and why:

- missing dependency
- no safe local environment
- needs remote secret or deployment credential
- unrelated existing repo failure

Do not claim a gate passed if only a narrower command was run.
