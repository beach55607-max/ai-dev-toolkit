# Adapter: `lg-liff`

Use this adapter for LIFF frontend apps, shared frontend modules, and frontend contracts with the worker.

## Ownership

This repo owns:

- LIFF app entrypoints
- Shared frontend modules
- Frontend interaction and payload composition
- GT and build-oriented verification for LIFF surfaces

## Boundary Model

Respect the split between:

- `shared/`
- `apps/*/`

Do not move app-specific logic into `shared/`. Do not treat worker payloads as frontend-only details when they cross repo boundaries.

## Protected Surfaces

See `constitution.md` for the canonical list. LIFF-specific additions:

- API payloads to the worker
- Auth token usage
- Environment-derived URLs and LIFF IDs
- Frontend state derived from backend response shapes

## Observability

- Preserve lightweight frontend observability and result metadata.
- Keep noisy diagnostics behind debug-only paths.
- If frontend output depends on backend response metadata, ensure the metadata remains lean by default.

## Validation

- Standard path: `npm run lint`, `npm run test`, `npm run build`
- Add GT or repo-documented verification when the phase docs or AGENTS require it.
- If the task changes backend-facing payloads, validate the consumer and producer sides together.

## Stop Conditions

Escalate when the task changes:

- payload or response wire format
- auth flow assumptions
- environment-driven endpoints
- shared module boundaries

## Common Mistake Scenario

**It looks like a small frontend payload change.**

Situation: a LIFF app needs one extra request field, or a field type changes from `string` to `string[]`.

A common approach is to update the form, the mapper, and the API client in `lg-liff`, then stop after `npm run test` passes.

What gets missed:

- The true owner is `lg-proxy-worker`, which validates and persists the field.
- The worker's validation may reject the new shape, or D1 may store it incorrectly.
- Other consumers of the same worker route may still send the old shape.

What the preflight catches:

- Step 2 (Owner) identifies `lg-proxy-worker` as the system of record.
- Step 3 (Contract) flags the request shape as a cross-repo surface.
- Step 7 (Validation) requires running `gate:pr` on the worker side too.
- The task gets reframed from "LIFF fix" to "contract change across `lg-liff` and `lg-proxy-worker`."