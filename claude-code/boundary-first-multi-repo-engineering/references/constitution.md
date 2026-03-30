# Constitution

This is the single source of truth for authority order and protected surfaces in the LG workspace. Other files reference this document instead of repeating these lists.

## Primary Principle

Keep AI-generated changes inside a range that is:

- controllable
- measurable
- acceptable
- reviewable

Translate that principle into code through:

- explicit ownership
- explicit boundaries
- explicit contracts
- explicit observability
- explicit validation

## What This Workflow Is

This is a collaboration-governance workflow, not a language or framework skill. Its purpose is to help Claude:

- choose the correct repo and owner surface
- avoid crossing architecture boundaries casually
- preserve security and contract integrity
- plan logging and debugging deliberately
- select the right mechanical checks before close-out

## Authority Hierarchy

1. User request
2. Repo-local `CLAUDE.md`, `AGENTS.md`, and task specs
3. Repo-local guards, tests, CI, logging facade, schema contracts
4. This workflow's constitution
5. This workflow's adapters

This workflow may tighten behavior but must not contradict a repo-local hard constraint.

## Collaboration Defaults

- Prefer boundary-first design over quick patches.
- Prefer adapting existing patterns over inventing new architecture.
- Prefer machine-checkable evidence over narrative confidence.
- Prefer compact operational logs that survive production use.
- Prefer opt-in debug instrumentation over always-on debug noise.

## Hard Rules

- **No source guessing.** If source files, `AGENTS.md`, or nearest tests were not read, do not assume implementation details. Read first, then act.
- **File safety.** Do not delete, move, rename, or broadly overwrite files simply to reduce complexity or silence failing paths. Read `AGENTS.md` and repo-local rules before cleanup or broad rewrites.
- **Rollback is mandatory for durable changes.** Any change to D1, KV, Sheets, or extension storage that does not state a rollback path, fallback, or blast-radius control cannot be closed out.
- **Cross-boundary safety requires both sides.** If a shared contract changes and only one side was validated, the task is not complete.
- **D2/D3 require maker-checker.** If the task touches protected surfaces at cross-repo or high-risk level, require a second-pass review or explicit user confirmation before marking as done.

## Protected Surfaces

Treat the following as design-time boundaries:

- auth or HMAC canonical behavior
- route names and request or response shapes
- schema fields and null semantics
- env bindings and feature flags
- D1/KV storage keys and durable writes
- permissions, host access, or message channels
- extension permissions and `host_permissions`
- observability fields that downstream systems rely on
- guard allowlists and guard scripts
- file deletes, broad moves, rename-heavy cleanup, and overwrite-heavy rewrites that change user-owned files or repo structure

## Global Stop Conditions

Escalate or slow down when the task touches:

- auth or HMAC canonical behavior
- schema rename or migration
- SQL conflict, delete, or rollback semantics
- guard allowlists or guard scripts
- extension permissions or host permissions expansion
- durable writes without clear rollback or acceptance evidence
