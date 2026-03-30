# Adapter: Frontend App

Use this adapter for web or mobile frontend apps, shared UI modules, and caller-side contract composition.

## Ownership

This runtime usually owns:

- page flow and user interaction
- client-side state and derived UI logic
- frontend environment wiring
- request composition before data crosses to a backend

## Protected Surfaces

Treat these as contract-sensitive:

- API payload composition
- auth token usage
- environment-derived endpoints
- frontend state derived from backend response shapes

## Validation

- start with the narrowest mapper, store, or component test
- run repo-standard lint and test
- run build verification
- validate producer and consumer together when backend-facing payloads change

## Stop Conditions

Escalate when the task changes:

- request or response wire format
- auth flow assumptions
- environment-driven endpoints
- shared module boundaries
