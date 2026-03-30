# Adapter: `lg-acl-sync`

Use this adapter for whitelist Sheet workflows, ACL sync, D1 health-check, role-sheet lifecycle, and GAS-side admin or HMAC coordination with the worker.

## Ownership

This repo owns:

- whitelist Sheet reading, formatting, and trigger/menu orchestration
- GAS-side payload building for user sync and store-list sync
- D1 health-check, pull-from-D1, and operator cleanup helpers
- PropertiesService-backed config and dynamic role-sheet mapping

Treat GAS-side Sheet workflow and trigger behavior as the local source of truth unless the task explicitly says the backend contract is changing.

## Boundary Model

This repo is a GAS sender and operator console for several worker contracts. If the task touches sync payloads, HMAC headers, pull/delete flows, or D1-facing admin operations, inspect `lg-proxy-worker` in the same turn.

## Protected Surfaces

See `constitution.md` for the canonical list. ACL-sync-specific additions:

- user-sync HMAC vs admin HMAC protocol split
- whitelist Sheet tab names and dynamic role-sheet mapping
- PropertiesService keys and script-level config expectations
- D1 health-check, pull, and delete semantics
- trigger installation and on-edit sync behavior

## Observability

- Keep operational logs focused on sync counts, role resolution, trigger activity, and D1 outcomes.
- Keep debug-heavy payload or canonical-string diagnostics opt-in and short-lived.
- Preserve user-facing warning text when failures may leave D1 partially updated.

## Validation

- Default: `npm run ci`
- Add narrower unit tests first for HMAC helpers, whitelist readers, payload builders, and D1 health-check logic.
- If worker contracts or durable delete paths change, validate the worker side in the same task.

## Stop Conditions

Escalate when the task changes:

- user-sync or admin HMAC canonical behavior
- whitelist Sheet schema or role normalization semantics
- D1 pull/delete semantics or partial-failure handling
- trigger installation, onEdit sync, or PropertiesService key meaning

## Common Mistake Scenario

**It looks like just a Sheet-side cleanup or sync helper tweak.**

Situation: the whitelist Sheet workflow needs a new role column, a trigger tweak, or a small change to D1 health-check cleanup.

A common approach is to update the GAS function, run `npm run ci`, and assume the worker will accept whatever the Sheet sends.

What gets missed:

- The worker still owns the backend contract, D1 delete semantics, and admin route expectations.
- A role rename or column shift can silently change payload meaning or break pull/delete reconciliation.
- Cleanup actions may be durable and only partially reversible if D1 already applied some deletes.

What the preflight catches:

- Step 3 (Contract) identifies the GAS-to-worker payload and admin HMAC as shared surfaces.
- Step 5 (State) forces a rollback or blast-radius stance for D1-facing cleanup.
- Step 4 (Security) checks whether the task is using the correct HMAC path and secret source.
- The task gets reframed from "tweak a Sheet helper" to "change a GAS-to-worker contract with durable-write risk."
