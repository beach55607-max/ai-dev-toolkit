# Architecture And Observability

Use this reference when the task changes module layout, route flow, shared utilities, instrumentation, or logging behavior.

## Boundary-First Rule

Design the boundary before editing implementation. Ask:

1. Which layer owns this behavior?
2. Which contract crosses the boundary?
3. Which guard, test, or gate will detect regression?
4. Which log or trace will prove runtime behavior?

If those answers are unclear, gather more context before coding.

## `lg-proxy-worker` Architecture

The repo AGENTS defines a feature-first layered structure:

- `entry`
- `routing`
- `features`
- `shared`

Treat these as hard boundaries, not suggestions. If a shortcut would violate them, redesign instead of patching around the guard.

Core boundary enforcement:

- `guard-architecture.mjs`
- `guard-repo-contracts.mjs`
- `guard-sql-safety.mjs`
- `guard-schema-contract.mjs`
- allowlist expiry governance

## Observability Defaults

### Normal Log

Use normal operational logging for:

- request or workflow start/end
- auth pass/fail
- route or decision outcome
- durable write success/failure
- fallback activation
- contract mismatch or data-quality warnings

Normal logs should be structured, trace-aware, compact, and cheap enough to keep on.

Prefer fields like: `traceId`, `event`, `module`, `status`, and compact metadata relevant to review or production support.

### `debug_log`

Use `debug_log` for:

- intermediate calculations
- raw payload previews
- branch-by-branch diagnostics
- expensive or noisy internal state
- temporary deep troubleshooting hooks

`debug_log` must be off by default, behind a flag or config switch, easy to enable during debugging, and easy to leave disabled in normal runtime.

The toggle can live in env/config, repo-level debug config, request-scoped diagnostic option, or injected logger implementation.

## Review Checklist

Before finishing, verify:

- the change respects the owning layer boundary
- the regression surface is covered by a guard, test, or gate
- normal logs are sufficient for production triage
- debug logs exist only where diagnostic depth is genuinely useful
- debug logs can be disabled cleanly