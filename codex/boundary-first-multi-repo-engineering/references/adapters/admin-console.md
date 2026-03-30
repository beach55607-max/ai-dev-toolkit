# Adapter: Admin Console

Use this adapter for internal dashboards, privileged review tools, moderation flows, and operator-driven sync or promotion work.

## Ownership

This runtime usually owns:

- operator-facing workflow logic
- review and approval surfaces
- privileged control paths
- admin-side coordination with backend services

## Protected Surfaces

See `constitution.md` for the canonical list. Admin-specific additions:

- role and permission checks for operator actions
- schema setup or promotion flows
- sync or bulk action payloads
- audit-oriented metadata and review states

## Validation

- Start with focused tests for the changed admin flow.
- Run repo-standard lint and test.
- Run the repo CI or build bundle when operator-visible behavior changes.

## Stop Conditions

Escalate when the task changes:

- permission model assumptions
- bulk-write or destructive actions
- review state semantics
- backend contracts used by admin tooling

## Common Mistake Scenario

**It looks like just one more admin bulk action.**

Situation: an admin console or automation flow needs a new bulk sync, bulk update, or review/promote action.

A common approach is to wire up the button and the API call, run the admin tests, and ship.

What gets missed:

- A bulk action is a durable write. If it writes 500 rows and fails at row 300, what happens to the first 299?
- There may be no rollback path. The data format after a partial write may be inconsistent.
- The review state or schema may change meaning after the bulk action completes.
- Validation should move up to integration or gate level, not stay at unit test level.

What the preflight catches:

- Step 4 (Security) flags this as a privileged admin flow with durable writes.
- Step 5 (State) requires identifying the rollback path before coding.
- Step 7 (Validation) escalates to integration-level verification.
- The task gets reframed from "add a button" to "design a durable write with rollback and partial-failure handling."
