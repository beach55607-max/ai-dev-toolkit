# Adapter: Backend Service

Use this adapter for API routes, auth, persistence, validation, queue handlers, or webhook work.

## Ownership

This runtime usually owns:

- request validation
- policy enforcement
- persistence
- shared backend contracts
- privileged write behavior

## Protected Surfaces

Treat these as contract-sensitive:

- routes and error envelopes
- auth headers, tokens, or signatures
- schema fields and null semantics
- storage keys and durable writes
- metadata that downstream systems persist or parse

## Validation

- start with route or handler-focused tests
- run repo-standard lint and test
- run the stronger gate or build path when auth, persistence, or shared contracts change

## Stop Conditions

Escalate when the task changes:

- auth or signature behavior
- destructive write flows
- schema migrations
- route names consumed by other systems
