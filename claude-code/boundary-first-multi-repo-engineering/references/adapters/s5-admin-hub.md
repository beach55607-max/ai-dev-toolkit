# Adapter: `lg-s5-admin-hub`

Use this adapter for GAS admin hub work: schema setup, sync, pull, backup, review, promote, and worker-admin contract alignment.

## Ownership

This repo owns:

- Sheet-side schema and menu flows
- Sync/pull orchestration
- Backup and validation behavior
- Admin review and promote UI flows

Treat `src/00_Schema.js` as the sheet-side source of truth unless the task explicitly states otherwise.

## Boundary Model

Treat this repo as the sender side of several worker admin contracts. If a change touches HMAC, sync payload, pull format, or review/promote APIs, inspect the worker receiver in the same turn.

## Protected Surfaces

See `constitution.md` for the canonical list. Admin-hub-specific additions:

- HMAC headers and canonical behavior
- Tab-to-route mapping
- Diff/full sync payload semantics
- Pull response cleanup rules
- Backup, lock, and trace logging around sync/pull

## Observability

- Keep trace-aware structured logging around sync, pull, validation, and batch sends.
- Use normal logs for lifecycle, validation, batch, and API outcome events.
- Use `debug_log` style output only for deep request diagnostics or canonical/HMAC troubleshooting.

## Validation

- Default: `npm run ci`
- Add narrower unit tests first for validator, sync, pull, or LLM admin flows.
- If contract behavior changes, validate both GAS and worker-side expectations.

## Stop Conditions

Escalate when the task changes:

- HMAC canonical behavior
- sync or pull wire format
- tab schema or primary key meaning
- rollback or versioning semantics

## Common Mistake Scenario

**It looks like just one more admin bulk action.**

Situation: the admin hub needs a new bulk sync mode or a batch review/promote action.

A common approach is to add the menu item, wire up the GAS function, and run `npm run ci`.

What gets missed:

- A bulk sync is a durable write to D1 via the worker. If it writes 500 rows and fails at row 300, the first 299 are already committed.
- The worker admin route may not have rollback or partial-failure handling for this new mode.
- The HMAC payload format for the new action must match exactly on both sides.

What the preflight catches:

- Step 4 (Security) flags this as a privileged admin flow with durable writes.
- Step 5 (State) requires identifying the D1 rollback path before coding.
- Step 3 (Contract) identifies the sync payload as a cross-repo surface.
- The task gets reframed from "add a menu item" to "design a durable write with cross-repo contract alignment and partial-failure handling."