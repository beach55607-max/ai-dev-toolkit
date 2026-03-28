# Cross-Boundary Contracts

Use this reference when one change can ripple into another repo, service, or runtime.

## Producer And Consumer Model

For every shared boundary, identify:

- which system produces the contract
- which system consumes it
- where the contract is validated
- where compatibility can silently drift

Do not treat request payloads, response shapes, schema fields, or env bindings as local-only details.

## Contract Checklist

Check whether the change affects:

- request fields and nullability
- response fields and error envelopes
- auth headers, tokens, or signatures
- route names or query params
- event names or message channels
- storage schema or durable-write format
- debug or metadata fields that downstream systems parse

If yes, inspect producer and consumer in the same turn.

## Design Guidance

- Prefer additive changes over breaking renames.
- If a breaking change is required, decide on versioning, dual-read, or staged rollout before coding.
- Keep contract ownership explicit; do not hide producer rules inside caller-side mappers.
- Treat metadata as part of the contract when the receiver stores, whitelists, or depends on it.

## Concrete Examples

### Example A: Field Type Change Ripple

Scenario: a frontend changes a request field from `string` to `string[]`.

- Producer: backend route that validates and persists the field.
- Consumer: frontend form that composes the request.
- Contract surface: request shape, validation rules, storage schema.
- What breaks silently: backend validation rejects the array; storage column expects a scalar; other consumers still send a string.
- Required: inspect and update producer validation, storage, and all consumers. Run validation on both sides.

### Example B: New Event Channel

Scenario: an automation worker adds a new event type to a shared message channel.

- Producer: automation worker publishing events.
- Consumers: backend handler and admin console that subscribe.
- Contract surface: event name, message shape, handler routing.
- What breaks silently: unhandled event type in consumers; missing handler falls through to a default or error path.
- Required: update all subscribers; add explicit handler or deliberate ignore in each consumer.

### Example C: Auth Header Change

Scenario: a backend changes the signature format for webhook verification.

- Producer: backend webhook sender.
- Consumer: extension or external service verifying signatures.
- Contract surface: auth headers, canonical string format.
- What breaks silently: all consumers fail signature verification immediately after deployment.
- Required: version the signature format or coordinate a staged rollout where consumers accept both old and new formats during a transition window.

## Validation Guidance

When a contract changes:

1. Run the narrowest caller-side test.
2. Run the narrowest producer-side test.
3. Run repo-standard validation in both systems.
4. Run the strongest gate on the system that owns auth, persistence, or schema.

Do not claim cross-boundary safety if only one side was exercised.
