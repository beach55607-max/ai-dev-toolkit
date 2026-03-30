# Adapter: `lg-linebot`

Use this adapter for GAS LINE Bot flows, whitelist/store-list sync, bot-side admin/auth integration, and trace-aware logging behavior.

## Ownership

This repo owns:

- GAS webhook and bot orchestration
- PropertiesService-backed config
- GAS-side admin or sync helpers
- Several logging and response-shape conventions

## Boundary Model

Preserve GAS platform constraints and existing protocol splits. If the task touches sync or admin behavior that talks to the worker, inspect the worker-side consumer as part of the same task.

## Protected Surfaces

See `constitution.md` for the canonical list. Linebot-specific additions:

- HMAC protocol split
- Response contract fields
- Trace-aware logging behavior
- Debug-only response fields
- Sheet and PropertiesService-backed SSOT

## Observability

- Prefer trace-aware operational logs for business events.
- Keep debug-only fields or diagnostics gated by config and excluded from lean contract responses by default.
- Distinguish between logs required for operations and diagnostics required only during troubleshooting.

## Validation

- Use repo-local lint and test commands from `package.json` and `AGENTS.md`.
- If the task touches GAS sync, HMAC, or response contracts, validate the nearest unit tests and any repo-documented CI bundle.

## Stop Conditions

Escalate when the task changes:

- HMAC split or canonical assumptions
- response contract compatibility
- SSOT config or main webhook entry
- debug-field gating or trace propagation assumptions

## Common Mistake Scenario

**It looks like a small sync transform update.**

Situation: the linebot needs to change how it maps store-list or whitelist data before syncing to the worker.

A common approach is to update the GAS transform function, verify the unit test passes, and ship.

What gets missed:

- The worker expects a specific payload shape. Changing the transform silently changes what the worker receives.
- The worker's D1 persistence may reject or misinterpret the new format.
- If the sync is not idempotent, rerunning it after the change may create duplicates.
- The HMAC canonical string may need to account for the new payload structure.

What the preflight catches:

- Step 3 (Contract) identifies the sync payload as a cross-repo surface with `lg-proxy-worker`.
- Step 5 (State) flags the D1 write as durable with limited rollback.
- Step 4 (Security) checks whether the HMAC path is affected.
- The task gets reframed from "update a mapper" to "contract migration affecting `lg-linebot` and `lg-proxy-worker`."