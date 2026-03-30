# Adapter: `lg-proxy-worker`

Use this adapter for Cloudflare Worker backend, D1/KV, routing, admin API, and backend contract work.

## Ownership

This repo owns:

- Worker routes and dispatch
- D1/KV access
- Backend feature logic
- Admin API behavior
- Many cross-repo contracts consumed by LIFF, GAS, and linebot surfaces

## Boundary Model

Treat the feature-first layers as hard boundaries:

- `entry`
- `routing`
- `features`
- `shared`

Do not cross them for convenience. Treat architecture guards and allowlist governance as design-time boundaries, not CI afterthoughts.

## Protected Surfaces

See `constitution.md` for the canonical list. Proxy-worker-specific additions:

- HMAC and admin auth
- Route paths and handler contracts
- D1/KV bindings
- SQL flow or conflict logic
- Schema contracts
- Allowlists and guard scripts

## Observability

- Prefer structured logs with `traceId`, compact event keys, and production-usable metadata.
- Put lifecycle, auth, fallback, durable-write, and contract decisions in normal logs.
- Put raw payload previews, branch diagnostics, and expensive internals behind `debug_log`.
- Keep debug output off by default via flag, config, or logger path.

## Validation

- Minimum for production-path work: `npm run gate:quick`
- Strong default for auth, routes, D1/KV, admin API, sync, rollback, or shared contract work: `npm run gate:pr`
- Do not stop at `npm run lint` or `npm run test` when the touched surface is high risk.

## Stop Conditions

Escalate or slow down if the task changes:

- auth/HMAC canonical format
- SQL conflict or delete behavior
- schema contract
- allowlist, suppression baseline, or guard scripts
- repo-wide architectural boundaries

## Common Mistake Scenario

**It looks like a small HMAC fix.**

Situation: the admin API's HMAC verification needs a tweak -- maybe changing the canonical string order or adding a body hash.

A common approach is to update the verification function in the worker, run `gate:quick`, and ship.

What gets missed:

- `lg-s5-admin-hub` is the sender side of this contract. Its HMAC construction must match exactly.
- `lg-linebot` may use a similar but different HMAC path. Changing one without checking the other can break an unrelated integration.
- There is no rollback for a deployed HMAC change -- all senders fail immediately.

What the preflight catches:

- Step 3 (Contract) identifies HMAC as a cross-repo contract surface.
- Step 4 (Security) flags this as high risk.
- Step 8 (Stop conditions) triggers escalation.
- The fix becomes: inspect all sender repos, stage the change with dual-format acceptance, then migrate senders.