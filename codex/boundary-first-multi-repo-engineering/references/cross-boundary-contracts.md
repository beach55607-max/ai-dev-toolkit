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

## Validation Guidance

When a contract changes:

1. Run the narrowest caller-side test.
2. Run the narrowest producer-side test.
3. Run repo-standard validation in both systems.
4. Run the strongest gate on the system that owns auth, persistence, or schema.

Do not claim cross-boundary safety if only one side was exercised.
