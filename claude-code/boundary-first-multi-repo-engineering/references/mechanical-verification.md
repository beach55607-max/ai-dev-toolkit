# Mechanical Verification

This reference explains why this workflow relies on mechanical verification instead of narrative confidence, what mechanical verification means in the LG workspace, and how to use it effectively.

## Core Principle

**Prefer machine-checkable evidence over narrative confidence.**

"I checked and it looks fine" is not evidence. A passing `gate:pr` with a known scope is evidence.

## What Counts As Mechanical Verification In The LG Workspace

### Guard Scripts

Small, focused scripts that check one invariant each. The LG workspace uses:

- `guard-architecture.mjs` — ensures imports respect `entry/routing/features/shared` layer boundaries
- `guard-repo-contracts.mjs` — ensures cross-repo contract shapes stay consistent
- `guard-sql-safety.mjs` — checks for dangerous SQL patterns (unqualified deletes, missing conflict targets)
- `guard-schema-contract.mjs` — ensures schema declarations match implementation
- `guard-secrets.mjs` — scans for hardcoded credentials or tokens
- `guard-encoding.mjs` — checks for unexpected character encoding issues
- `guard-imports.mjs` — validates import path patterns
- `guard-hardcoding.mjs` — catches hardcoded values that should be config
- `guard-barrels.mjs` — checks barrel file conventions
- `guard-critical-tests.mjs` — verifies critical test coverage
- `guard-deprecated-surface.mjs` — flags use of deprecated APIs
- `guard-sql-contract.mjs` — validates SQL against contract definitions

Guard scripts are fast, deterministic, and cheap to run. They catch regressions that unit tests do not cover.

### Gate Commands

#### `lg-proxy-worker`

- `npm run gate:quick` — lint + guards + fast tests. Use for routine changes. (< 30 seconds)
- `npm run gate:pr` — lint + guards + full tests + contract checks + build. Use when auth, persistence, schema, routes, HMAC, admin API, sync, rollback, or shared contracts are touched.

**Rule: if the touched surface is high risk, use `gate:pr`, not just `gate:quick`.**

#### `lg-s5-admin-hub`

- `npm run ci` — lint + tests + duplicate detection

#### `lg-liff`

- `npm run lint` + `npm run test` + `npm run build`
- Add GT or repo-specific verification when AGENTS or phase docs require it.

#### `lg-linebot`

- Repo-local lint and test commands from `package.json` and `AGENTS.md`.

#### `lg-acl-sync`

- `npm run ci` — lint + tests

#### `lg-thinq-ext`

- `npm run lint` + `npm run test` + `npm run build`

### Green Tests (GT)

GT means all tests pass, not just the ones near the changed code. "GT confirmed" means the full suite is green.

GT is the baseline. If GT fails, the change is not ready regardless of what narrative confidence says.

### Contract Tests

Tests that verify the shape and behavior of a shared boundary between two LG repos.

Examples:

- a test that asserts the LIFF request schema matches what `lg-proxy-worker` validates
- a test that verifies HMAC computation matches between `lg-s5-admin-hub` sender and `lg-proxy-worker` receiver
- a test that asserts the sync payload shape matches what the worker consumer expects

Contract tests catch the exact class of failure this workflow is designed to prevent: silent drift between producer and consumer.

## Verification Depth Ladder

### Level 1: Lint + Unit Tests

Sufficient for: D0 changes with no protected surface.

### Level 2: Guards + Narrowest Tests

Sufficient for: D0/D1 changes that touch production code but not protected surfaces.

### Level 3: `gate:quick`

Use for: D0 (`guards/gate-quick-d0.md` from executable-spec-planning skill) or D1 changes that touch a protected surface within one repo.

### Level 4: `gate:pr` / `npm run ci`

Use for: D1 high-risk and D2 changes. Auth, HMAC, persistence, schema, routes, shared contracts, durable writes.

### Level 5: Cross-Repo Validation

Use for: D2/D3 changes that affect a shared contract. Run the strongest gate on both repos. One-side-only validation is partial evidence, not a pass.

### Level 6: Staged Rollout Verification

Use for: D3 changes that cannot be safely verified in a single deployment. HMAC format changes, D1 schema migrations, breaking contract changes.

## Anti-Patterns

- **"I ran lint and it passed"** — lint checks syntax, not semantics. It does not verify architecture, contracts, or security.
- **"The tests near my change pass"** — narrowest tests verify local behavior. They do not verify cross-boundary impact.
- **"I read the code and it looks correct"** — reading is valuable for understanding, but it is not verification.
- **"The build succeeded"** — a build verifies compilation, not correctness. Many contract and auth failures build successfully.
- **"No gate available"** — a valid answer, but it must be stated explicitly in close-out, not hidden behind narrative confidence.

## Verification Failure Triage

When gate or test failures occur, do not fix randomly. Use structured triage.

### Step 1: Run the full suite

Run the strongest available gate (`gate:pr`, `npm run ci`). Collect all failures.

### Step 2: Group failures by root cause

- **Invariant failures** — `guard-architecture`, `guard-imports`, `guard-barrels`, `guard-encoding`. Fix first — they cause cascading failures.
- **Contract failures** — `guard-repo-contracts`, `guard-schema-contract`, `guard-sql-contract`, request/response shape mismatches. Fix second — they affect cross-repo correctness.
- **Security failures** — `guard-secrets`, auth downgrade, HMAC canonical drift, permission expansion. Fix with high priority.
- **Regression failures** — existing behavior changed unintentionally. Fix after invariant and contract groups are stable.

### Step 3: Fix by group, verify per group

Fix one group. Run the relevant guard or test subset. Confirm resolved before moving to next group.

### Step 4: Full suite again

Run the full gate one final time. Do not claim GT until the full suite passes.

## Connection To This Workflow

- **Preflight Step 7** requires mapping validation depth to risk. The depth ladder above is the mapping.
- **Decision Gate** uses verification availability to determine ceremony level.
- **Close-out** requires stating which checks ran, which were skipped, and why.
- **Constitution** states: "Prefer machine-checkable evidence over narrative confidence." This reference is what that means in practice.