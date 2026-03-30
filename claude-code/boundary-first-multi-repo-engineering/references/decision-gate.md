# Decision Gate

Use this reference before preflight to classify the change severity and determine the required level of ceremony.

## Severity Levels

### D0 — Local Implementation

The change is confined to a single repo, does not touch any protected surface (see `constitution.md`), and has no cross-boundary impact.

**D0 requires ALL of the following**:
- No information output (new Flex/API/LLM responses/report formats)
- No new data fields or sources (new D1 tables, Sheet columns, KV keys)
- No cross-module changes (3+ files across different directories)
- No permission/security logic (ACL, HMAC, rate limiting)
- No SQL mutation changes (INSERT/UPDATE/DELETE)
- Affected files ≤ 3

**D0 still requires**: Step 2b (Query Actual Data) + Evidence Block + BDD AC format (data computation) + Ubiquitous Language Table (cross-system) + Code Quality Constraints (cross-module) + Bug-to-Gate Closure (HR-8, bug fix only). See `executable-spec-planning` skill for full spec requirements.

- Proceed directly to preflight.
- Use `guards/gate-quick-d0.md` (from executable-spec-planning skill) or standard repo lint and test.

### D1 — Single-Repo Protected Surface

The change touches a protected surface within one repo but does not cross a contract boundary.

Examples: adding a route in `lg-proxy-worker`, changing a KV key, modifying HMAC logic within the worker.

Before preflight, confirm:

- Assumption: what behavior is expected to change.
- Owner: which repo and layer.
- Rollback stance: what happens if this needs to be reverted.

### D2 — Cross-Boundary Contract Change

The change affects a shared contract between two or more LG repos.

Examples: LIFF request shape change that affects `lg-proxy-worker`, admin hub sync payload format change, linebot store-list schema change.

Before preflight, confirm:

- Decision note: why this change is needed and what alternatives were considered.
- Producer and consumer impact: which repos break if the contract changes.
- Validation plan: how both sides will be verified (e.g., `gate:pr` on worker + `npm run ci` on admin hub).
- Rollback stance: whether a staged rollout or dual-format transition is needed.

### D3 — High-Risk Governance Change

The change involves auth/HMAC canonical behavior, schema migration, destructive writes, permission model changes, or guard script modifications.

Examples: HMAC canonical format change, D1 column rename, SQL delete semantics change, extension `host_permissions` expansion, guard allowlist modification.

Before preflight, confirm everything from D2, plus:

- Explicit user confirmation before implementation begins.
- Maker-checker: require a second-pass review or explicit escalation before close-out.
- Blast radius assessment: how many repos, systems, or data records are affected.

## Decision Flow

```
Is a protected surface touched? (includes: information output, new data fields,
  cross-module 3+ files, permission/security, SQL mutations)
  NO and affected files ≤ 3 -> D0. Proceed to preflight.
  YES -> Does it cross a repo boundary?
    NO  -> D1. Confirm assumption, owner, rollback. Then preflight.
    YES -> Does it involve auth/HMAC, schema migration, destructive writes, or permissions?
      NO  -> D2. Write decision note and validation plan. Then preflight.
      YES -> D3. Get user confirmation. Write decision note. Then preflight.
```

## Implementation Plan

For D1/D2/D3 tasks, use the template in `implementation-plan-template.md` to document assumption, owner, contract/security surfaces, validation plan, and rollback stance before coding.

## Rules

- **No source guessing.** If source files, `AGENTS.md`, or nearest tests were not read, do not assume implementation details. Read first, then classify.
- **Rollback is mandatory for durable changes.** Any change to durable state (D1, KV, Sheets, extension storage) that does not state a rollback path, fallback, or blast-radius control cannot be closed out.
- **Cross-boundary safety requires both sides.** If a shared contract changes and only one side was validated, the task is not complete. This is a hard rule, not a suggestion.
- **D2/D3 require maker-checker.** If the task touches protected surfaces at D2 or D3 level, require a second-pass review or explicit user confirmation before marking as done. Minimum evidence for maker-checker: (a) user explicitly confirmed the approach before implementation, or (b) a second review pass was requested and the user approved, or (c) the user explicitly waived review. State which evidence applies in close-out.
