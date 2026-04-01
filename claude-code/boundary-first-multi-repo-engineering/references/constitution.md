# Constitution

This is the single source of truth for authority order and protected surfaces. Other files reference this document instead of repeating these lists.

## Purpose

This workflow improves engineering judgment for multi-repo and multi-runtime work. It tightens boundary reasoning without overriding repo-local truth.

## Order Of Authority

1. Explicit user request
2. Repo-local instructions (`CLAUDE.md`, `AGENTS.md`, specs, guardrails)
3. Executable checks (tests, gates, builds, CI definitions)
4. This workflow and its references

If local rules conflict with this workflow, follow the local rules and explain the conflict.

## Boundary-First Principle

Before editing, identify:

- the system of record
- the caller or consumer
- the contract boundary between them
- the high-risk surfaces affected by the change

Do not start implementation while the owner boundary is still implicit.

## Protected Surfaces

Treat the following as design-time boundaries:

- auth or signature behavior
- route names and request or response shapes
- schema fields and null semantics
- env bindings and feature flags
- storage keys and durable writes
- permissions, host access, or message channels
- observability fields that downstream systems rely on
- file deletes, broad moves, rename-heavy cleanup, and overwrite-heavy rewrites that change user-owned files or repo structure

## Hard Rules

- **No source guessing.** If source files, local rules, or nearest tests were not read, do not assume implementation details. Read first, then act.
- **File safety.** Do not delete, move, rename, or broadly overwrite files simply to reduce complexity or silence failing paths. Read repo-local instructions before cleanup or broad rewrites.
- **Rollback is mandatory for durable changes.** Any change to durable state that does not state a rollback path, fallback, or blast-radius control cannot be closed out.
- **Cross-boundary safety requires both sides.** If a shared contract changes and only one side was validated, the task is not complete.
- **D2/D3 require maker-checker.** If the task touches protected surfaces at cross-boundary or high-risk level, require a second-pass review or explicit user confirmation before marking as done.
- **Phase transitions require PM ACK (with proportionality) (HR-10).** D2/D3: every Gate must stop and wait for PM APPROVED / REVISE / REJECT. D0: G0 and G6 always stop for PM; G1~G5 may use `SELF_CERTIFIED(evidence)` with mechanical evidence. D1: G0, G2(Spec Lock), G5(Review), and G6 always stop for PM; G1, G3, G4 may self-certify — PM reviews all self-certified Gates at G6. Agent uncertainty at any D-level = stop and ask PM. See Universal Gate Protocol reference.
- **Phase skipping is a stop condition.** Skipping any Gate without `WAIVED_BY_PM(reason)` is a stop condition. The agent must issue a WAIVE REQUEST and wait for PM response. Unilateral phase skipping is never acceptable. (Related: HR-9 Governance Audit mandatory, HR-10 Phase transitions.)

## Finish Criteria

A task is not done just because code compiles. Finish only when owner, risk surface, validation evidence, and residual risk are clear enough for another engineer to review quickly.
