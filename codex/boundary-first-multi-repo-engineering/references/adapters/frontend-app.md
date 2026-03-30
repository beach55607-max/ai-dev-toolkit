# Adapter: Frontend App

Use this adapter for web or mobile frontend apps, shared UI modules, and caller-side contract composition.

## Ownership

This runtime usually owns:

- page flow and user interaction
- client-side state and derived UI logic
- frontend environment wiring
- request composition before data crosses to a backend

## Protected Surfaces

See `constitution.md` for the canonical list. Frontend-specific additions:

- API payload composition and request shapes
- auth token usage and session handling
- environment-derived endpoints and feature flags
- frontend state derived from backend response shapes

## Validation

- Start with the narrowest mapper, store, or component test.
- Run repo-standard lint and test.
- Run build verification.
- Validate producer and consumer together when backend-facing payloads change.

## Stop Conditions

Escalate when the task changes:

- request or response wire format
- auth flow assumptions
- environment-driven endpoints
- shared module boundaries

## Common Mistake Scenario

**It looks like a small frontend payload change.**

Situation: a frontend flow needs one extra request field, or a field type changes from `string` to `string[]`.

A common approach is to update the form, the mapper, and the API client, then stop after a frontend test passes.

What gets missed:

- The true owner is not the frontend. It is the backend route that validates and persists the field.
- The backend validation may reject the new shape silently or store it incorrectly.
- Other consumers of the same endpoint may still send the old shape.
- This is not a UI change. It is a contract change.

What the preflight catches:

- Step 2 (Owner) identifies the backend as the system of record because it owns validation and persistence.
- Step 3 (Contract) flags the request shape as a shared surface.
- Step 7 (Validation) requires running tests on both producer and consumer sides.
- The task gets reframed from "frontend fix" to "contract migration with frontend and backend changes."
