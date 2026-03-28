# Adapter: Admin Console

Use this adapter for internal dashboards, privileged review tools, moderation flows, and operator-driven sync or promotion work.

## Ownership

This runtime usually owns:

- operator-facing workflow logic
- review and approval surfaces
- privileged control paths
- admin-side coordination with backend services

## Protected Surfaces

Treat these as contract-sensitive:

- role and permission checks
- schema setup or promotion flows
- sync or bulk action payloads
- audit-oriented metadata and review states

## Validation

- start with focused tests for the changed admin flow
- run repo-standard lint and test
- run the repo CI or build bundle when operator-visible behavior changes

## Stop Conditions

Escalate when the task changes:

- permission model assumptions
- bulk-write or destructive actions
- review state semantics
- backend contracts used by admin tooling
