# Adapter: Backend Service

Use this adapter for API routes, auth, persistence, validation, queue handlers, or webhook work.

## Ownership

This runtime usually owns:

- request validation and policy enforcement
- persistence and storage schema
- shared backend contracts consumed by frontends, admin tools, and automation
- privileged write behavior and transaction boundaries

## Protected Surfaces

See `constitution.md` for the canonical list. Backend-specific additions:

- routes and error envelopes
- database schema, migration order, and conflict resolution logic
- queue or webhook handler registration

## Validation

- Start with route or handler-focused tests.
- Run repo-standard lint and test.
- Run the stronger gate or build path when auth, persistence, or shared contracts change.

## Stop Conditions

Escalate when the task changes:

- auth or signature behavior
- destructive write flows
- schema migrations
- route names consumed by other systems

## Common Mistake Scenario

**It looks like a small auth fix.**

Situation: a backend needs to change how it computes a webhook signature -- maybe switching from a simple hash to an HMAC with a canonical string.

A common approach is to update the signing function, verify the backend tests pass, and ship. But this is a contract change, not a local fix.

What gets missed:

- Every consumer that verifies the signature will fail immediately after deployment.
- There may be multiple consumers (frontend, extension, external service) each with their own verification code.
- There is no rollback path if the change is deployed without a transition window.

What the preflight catches:

- Step 3 (Contract) identifies the signature as a shared contract surface.
- Step 4 (Security) flags this as high risk.
- Step 8 (Stop conditions) triggers an escalation before coding begins.
- The fix becomes a staged rollout: accept both old and new formats, migrate consumers, then remove the old format.
