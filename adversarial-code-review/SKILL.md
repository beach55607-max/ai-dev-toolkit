---
name: adversarial-code-review
description: "Adversarial code review skill for AI-assisted development. Use whenever reviewing code, specs, PRs, or AI-generated output for correctness. Triggers on: 'review this code', 'check this PR', 'audit', 'verify implementation', 'is this correct', 'does this match spec', any code review request, any spec-vs-code verification, any AI output validation. This skill encodes a falsification-first review methodology distilled from 30+ real incidents where AI reviewers gave wrong answers."
---

# Adversarial Code Review

> **Core Principle**: The purpose of review is not to confirm "looks correct," but to prove "cannot be falsified."
> Every PASS verdict requires positive evidence + falsification scenario exclusion. A PASS without evidence = review failure.

---

## How This Skill Works

This skill has **three review modes**. Select the mode that matches your review target:

### Mode Selection

| Mode | When to Use | What Gets Checked |
|------|------------|-------------------|
| **Code Mode** | Reviewing code changes, PRs, AI-generated code | §2-Code checklist, execution evidence required |
| **Spec Mode** | Reviewing specs, design docs, architecture proposals | §2-Spec checklist, logical completeness required |
| **Release Gate Mode** | Pre-deploy verification of completed work | Both checklists + deploy verification + cross-validation |

### Intensity Selection (map to your risk classification)

| Intensity | When | What to Run |
|-----------|------|-------------|
| **L1 Fast** | Low-risk, no protected surface (typo, comment, UI copy) | §1 Q1+Q2 only, skip checklists |
| **L2 Standard** | Normal feature work within one service | Full §1 + §2 + §3 |
| **L3 Adversarial** | Cross-service, schema change, auth, durable writes, deployment | Full §0-§8 including self-falsification and pattern expansion |

If your project uses a severity classification (D0-D3 or similar), map it:
- D0 → L1 Fast
- D1 → L2 Standard
- D2/D3 → L3 Adversarial

### What This Skill Is NOT

- **Not a CI/CD replacement.** This skill reviews; it doesn't build, test, or deploy.
- **Not a deploy governance framework.** Owner, rollback, blast radius decisions are your team's responsibility.
- **Not a schema migration tool.** Schema governance requires its own framework.
- **Not automatic approval.** A PASS means "reviewer verified with evidence," not "safe to ship."

If your team needs deploy governance, pair this with a boundary-first engineering workflow or your existing deploy process.

---

## §0 Calibration Cases

Read these before your first review. All are **real incidents where AI reviewers gave wrong answers**.

> See [references/calibration-cases.md](references/calibration-cases.md) for full case details.

**Summary of failure patterns:**

| Case | AI Said | Reality | Lesson |
|------|---------|---------|--------|
| C-1 | "Adapter returns raw data correctly" | DB stores `'ACTIVE'` (uppercase), code compares `'active'` (lowercase) → all items misclassified | **Test mock values must reflect production data format, not code expectations** |
| C-2 | "Can reuse existing query logic for new data source" | Same field name, different semantics (computed vs raw) → stale data returned | **Same field name in different sources can have completely different definitions** |
| C-3 | "Hardcoded default is a code smell" | Upstream adapter already handles mapping; default is defensive fallback | **Trace at least one layer up AND down before concluding** |
| C-4 | "Consistency check is implemented" | Code only logs mismatch, no actual fallback branch | **"Has log" ≠ "Has handling"** |
| C-5 | "After writing to cache, next read returns new value" | Edge cache with 24h TTL not invalidated by store write | **Platform consistency model must be verified, not assumed** |
| C-6 | "Spec says feature X is filtered, so code does it" | Code has no such filter; spec described intent, not implementation | **Verify code against spec, never spec against code** |
| C-7 | "All tests pass, conflict handling is correct" | Test mock doesn't run real SQL; production constraint differs from code assumption → silent data loss | **Test mocks don't validate SQL semantics** |
| C-8 | "Function is updated, just re-execute" | Editor shows new code but runtime runs cached old version | **Deployment state must be verified, not trusted** |

---

## §1 Four Mandatory Questions

**Every review item must answer these 4 questions. Missing any one = incomplete review.**

### Q1: Positive Evidence

> "What specific code line / test case / log output is your PASS based on?"

- Must cite specific file path + line number or function name
- "I read the code and it looks right" is NOT evidence
- No line-number citation → auto-downgrade to 🟡 UNVERIFIED

### Q2: Falsification Scenario

> "Under what conditions would this code produce wrong results? Did you verify those scenarios?"

- List at least 2 boundary conditions that could cause failure
- If you cannot think of any → explain why (pure function / exhaustive test)
- C-1 and C-2 are cases where falsification scenarios were missed

### Q3: Boundary Data Validation

> "What real data / golden test / manual calculation did you use to verify correctness?"

- Mock PASS ≠ production PASS (C-1 lesson)
- For numeric calculations: show arithmetic for at least 1 real scenario, **with formula and result**
- For JOINs / queries: list actual key values and matching logic

### Q4: Path Execution Evidence

> "Has the fallback / error / edge-case code path actually been exercised? Evidence?"

- Log exists ≠ path exercised (C-4 lesson)
- Test covers happy path ≠ error path tested
- No execution evidence → 🟡 UNVERIFIED, not ✅ PASS

---

## §2-Code: Code Review Checklist

### CL-1: Database Queries

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | JOIN key field names + case match? | C-1: `'ACTIVE'` vs `'active'` |
| 2 | Conflict/upsert constraint matches actual unique index? | C-7: constraint name mismatches production schema |
| 3 | Query parameters are parameterized (no string concatenation)? | Dynamic SQL = injection risk |
| 4 | WHERE covers all necessary filters? | Missing status filter → returns deleted/inactive rows |
| 5 | Batch `IN (?)` correctly expanded? | Some DBs don't support array params; must expand to `IN (?,?,?)` |
| 6 | NULL handling: `= ?` doesn't match NULL, need `IS NULL` | Missing NULLs → no results but no error |
| 7 | DDL/DML logic changes verified against production schema? | C-7: mock PASS but real constraint differs |

### CL-2: Cache / Storage Keys

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Key prefix has no namespace collision? | `user:session:` vs `user:settings:` overlap |
| 2 | Cache TTL + invalidation strategy correct? | C-5: edge cache independent from store writes |
| 3 | CLI commands target correct environment (remote vs local)? | Default may operate on local storage |
| 4 | Key format change has migration for old-format keys? | Old keys orphaned, no read path |
| 5 | Feature flag fallback chain correct? | Flag store → config → hardcode, each layer verified |

### CL-3: Data Semantics

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Same field name in different sources has same definition? | C-2: `availableQty` computed vs raw |
| 2 | Adapter layer normalizes all enum/status values? | C-1: raw pass-through |
| 3 | Numeric unit and precision consistent? | Integer vs float, currency mismatch |
| 4 | Timestamp format and timezone consistent? | ISO 8601 + UTC vs local timezone |
| 5 | Mock values reflect real production data format? | C-1: mock matches code but not production |
| 6 | Calculation formula matches spec / other system? | Manual arithmetic verification |
| 7 | After deployment, is runtime actually executing new version? | C-8: editor shows new but runtime runs cached old |

### CL-4: Fallback / Error Handling

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Error path has concrete handling (not just logging)? | C-4: logs warning but no fallback branch |
| 2 | Fallback return value: does caller have null check? | Fallback returns null, caller assumes non-null |
| 3 | try-catch doesn't swallow important errors? | `catch(e) {}` silent swallow |
| 4 | Timeout has upper bound? Behavior when exceeded? | API response deadlines, platform execution limits |
| 5 | Circuit breaker / kill switch is exercisable? | Config key exists ≠ code reads and branches on it |
| 6 | Rollback executable within acceptable timeframe? | Config rollback (seconds) vs code deploy (minutes) |

### CL-5: Temporal / Cross-Phase Dependencies

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Current workaround survives next phase? | Write-through removed in future phase breaks read path |
| 2 | Feature flag lifecycle has removal spec? | Flag switch without rollback path |
| 3 | Defense mechanism works after dependency removed? | Fallback depends on soon-to-be-retired service |
| 4 | Test mocks updated after schema change? | DDL adds column but test fixture is stale |
| 5 | Both sides of cross-service API updated together? | One side changes contract, other side doesn't follow |

---

## §2-Spec: Spec Review Checklist

### CL-S1: Requirements Completeness

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Boundary conditions defined? (empty, zero, max, single item) | "Supports batch processing" — what if batch = 0? |
| 2 | Exception scenarios enumerated? | Only happy path described |
| 3 | Undefined behavior explicitly called out? | Implicit "won't happen" assumptions |
| 4 | Acceptance criteria mechanically decidable? | "Works correctly" is not testable |
| 5 | Scope boundaries explicit? What is NOT in scope? | AI agent scope creep |

### CL-S2: Internal Consistency

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Numbers agree across sections? | §3 says "≤4 queries" but §5 implies N queries |
| 2 | State transitions complete? (every state has defined exits) | Status has active/inactive but no reactivation path |
| 3 | Timing / ordering assumptions explicit? | Assumes System A completes before System B reads |
| 4 | Terminology consistent throughout? | "User" vs "member" vs "account" used interchangeably |

### CL-S3: Implementability

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Vague verbs identified? ("handle", "process", "manage") | Implementer doesn't know what to build |
| 2 | Hidden dependencies surfaced? | Requires data from system not mentioned in spec |
| 3 | Performance claims have backing math? | "Improves performance" — by how much? measured how? |
| 4 | Rollback defined per phase? | No recovery path if phase 3 fails |

### CL-S4: Data Contract

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Field names, types, nullability defined? | "Returns user data" — which fields? nullable? |
| 2 | Cross-system field semantics aligned? | Same field name, different meaning (C-2 pattern) |
| 3 | Enum values exhaustive + normalized? | Case mismatch between systems (C-1 pattern) |
| 4 | Schema migration path defined for breaking changes? | New column added but consumers not updated |

### CL-S5: Security / Permissions / State Machine

| # | Check | Typical Error |
|---|-------|---------------|
| 1 | Role × operation matrix defined? | "Admin can manage" — manage what exactly? |
| 2 | Auth/signing format identical on sender and receiver? | Canonical format drift |
| 3 | Durable write has rollback stance? | Bulk delete with no undo path |
| 4 | State transitions have authorization gates? | Any user can transition any status |

---

## §3 Six Anti-Patterns (Prohibited Review Behaviors)

### AP-1: "Looks Good" Rubber Stamp

- :x: "This code looks correct"
- :white_check_mark: "This code at `file.js:L42` does X, which matches spec §3.2 requirement Y. Falsification scenario Z is covered by test case TC-05."

### AP-2: Trust Mock = Trust Production

- :x: "All tests pass so logic is correct"
- :white_check_mark: "Tests PASS proving code matches mock. But need to verify mock values reflect production data format (C-1 lesson)."

### AP-3: Verify Code With Spec (Causation Reversed)

- :x: "Spec says it filters active items, so code must do it"
- :white_check_mark: "Spec says it filters active items. I searched the function — no active-related filter found. This is a spec-code gap." (C-6 lesson)

### AP-4: Log Exists = Handling Exists

- :x: "There's a `console.warn('mismatch')` so it's handled"
- :white_check_mark: "`console.warn` at L55, but L56 continues using stale result. No if/else branch for fallback path." (C-4 lesson)

### AP-5: Stop at First Layer

- :x: "`|| 'DEFAULT'` is a hardcoding risk"
- :white_check_mark: "`|| 'DEFAULT'` at L30. Tracing upstream: caller at adapter.js:L88 already maps the raw field. `|| 'DEFAULT'` is defensive fallback, not hardcoding." (C-3 lesson)

### AP-6: Assume Platform Behavior

- :x: "After cache write, next read returns new value"
- :white_check_mark: "Platform uses eventually consistent caching. Edge cache with TTL is not invalidated by store writes. Need versioned keys or short TTL." (C-5 lesson)

---

## §4 Verdict Levels

| Level | Symbol | Definition | Condition |
|-------|--------|------------|-----------|
| FAIL | :red_circle: | Confirmed bug or spec-code gap | Specific code line + reproducible scenario |
| UNVERIFIED | :yellow_circle: | Cannot confirm correctness | Any Q1-Q4 unanswerable, or lacks production evidence |
| PASS | :white_check_mark: | Confirmed correct | All Q1-Q4 answered with positive evidence + falsification excluded |
| N/A | :black_medium_square: | Not applicable | Checklist item not relevant in this context |

**Escalation rules:**

- :yellow_circle: can downgrade to :red_circle: (found concrete falsification)
- :yellow_circle: can upgrade to :white_check_mark: (supplied missing Q1-Q4 evidence)
- :white_check_mark: cannot revert to :yellow_circle: (unless new falsification found)
- Any :red_circle: in review → overall NO-GO

---

## §5 Self-Falsification (L3 only)

After finding an issue, **spend equal effort trying to disprove your own finding**:

1. For each :red_circle: finding, construct a "actually this is fine" argument
2. If you can disprove it → downgrade to :yellow_circle: or remove
3. If you can't disprove it → keep :red_circle: and record the disproof attempt as extra evidence
4. For each :white_check_mark:, ask: "Which calibration case pattern (C-1 through C-8) could repeat here?"

**Purpose**: Prevent over-reporting (padding findings) and under-reporting (confirmation bias).

---

## §6 Same-Pattern Expansion (L2+ only)

When you find a bug or flag an issue, ask:

1. **"Where else does this same pattern exist?"** — Other fields in the same adapter? Other queries with the same JOIN?
2. **"Where else is this assumption used?"** — If a mock format is wrong, are other test mocks also wrong?
3. **"Who would this fix break?"** — If you add `.toLowerCase()`, does downstream expect uppercase?

In Claude Code / agents with repo access: use grep to search. In Codex / paste-based review: remind the reviewer to search manually.

---

## §7 Execution-Layer Audit (Release Gate mode only)

| Layer | Action | Method | Catches |
|:-----:|--------|--------|---------|
| 1 | Static Check | **Execute** linter / grep / field scan / injection scan | Syntax + stale references |
| 2 | Behavioral Check | **Execute** tests (targeted + full) / schema verification | Mock-layer correctness + schema alignment |
| 3 | Code Review | **Read** changed files → compare against spec item by item | Spec-code gap |
| 4 | Cross-Impact | **Execute** `git diff` + `grep` for unchanged files + stale references | Side effects + scope creep |
| 5 | Test Quality | **Read** test files → compare against coverage gates | Test blind spots |

**Trust Calibration**: Embed 2 known bugs in the review prompt. If the reviewer doesn't find them independently → report credibility is discounted.

**Hard Rule**: Layers 1-2 require **execution output evidence**, not "I read it and it looks fine."

---

## §8 Output Template

```markdown
# Adversarial Code Review Report

## Meta
- **Reviewer**: [identity]
- **Target**: [PR# / file / spec document]
- **Date**: YYYY-MM-DD
- **Mode**: Code / Spec / Release Gate
- **Intensity**: L1 Fast / L2 Standard / L3 Adversarial
- **Overall**: 🔴 NO-GO / 🟡 CONDITIONAL-GO / ✅ GO

## Findings

### [F-01] [Title]
- **Level**: 🔴 / 🟡 / ✅
- **Location**: `file.js:L42-L55` / `spec §3.2`
- **Description**: [specific issue]
- **Q1 Positive Evidence**: [code line / test case]
- **Q2 Falsification Scenario**: [what conditions cause failure]
- **Q3 Data Validation**: [what data verified / arithmetic result]
- **Q4 Path Execution**: [was fallback tested]
- **Self-Falsification** (L3): [attempt to disprove this finding]
- **Same Pattern** (L2+): [does this exist elsewhere]
- **Suggested Fix**: [concrete action]

## Checklist Summary

### Code Mode
| Checklist | ✅ | 🔴 | 🟡 | ⬛ |
|-----------|:--:|:--:|:--:|:--:|
| CL-1 Database | | | | |
| CL-2 Cache/Storage | | | | |
| CL-3 Data Semantics | | | | |
| CL-4 Fallback/Error | | | | |
| CL-5 Temporal/Cross-Phase | | | | |

### Spec Mode
| Checklist | ✅ | 🔴 | 🟡 | ⬛ |
|-----------|:--:|:--:|:--:|:--:|
| CL-S1 Completeness | | | | |
| CL-S2 Consistency | | | | |
| CL-S3 Implementability | | | | |
| CL-S4 Data Contract | | | | |
| CL-S5 Security/Permissions | | | | |

## Execution Evidence (Code Mode L2+ required)

| # | Command / Action | Output Summary | Reviewer Conclusion |
|---|-----------------|---------------|---------------------|
| 1 | [e.g. `npm test -- --grep "batch"`] | [PASS/FAIL + key numbers] | [What this proves / doesn't prove] |
| 2 | [e.g. `grep -rn 'ON CONFLICT' src/`] | [N matches listed] | [Matches production schema / doesn't] |

If execution is not possible (paste-based review), write: "N/A — recommend reviewer manually execute: [commands]"

## Trust Test (if applicable)
- **Known Bug 1**: [Did PM embed a known bug? Was it found?]
- **Known Bug 2**: [Same]
- **Credibility rules**:
  - 2/2 found → report credibility HIGH
  - 1/2 found → report credibility MEDIUM, recommend second reviewer
  - 0/2 found → report credibility LOW, report needs redo or owner review

## Deploy Verification (Release Gate mode)
| Step | Command / Action | Expected Result |
|------|-----------------|-----------------|
| 1 | Deploy | [deploy command] |
| 2 | Trigger test scenario | [which query / which data] |
| 3 | Verify logs | [which log key, expected value] |
| 4 | Cross-validate | [compare two independent paths] |

## Reviewer Honest Disclosure
- **Not verified**: [honestly list]
- **Assumptions made**: [list]
- **Suggested next step**: [who needs to verify what, how]
```

---

## §9 Review Flow

```
1. Select Mode (Code / Spec / Release Gate)
2. Select Intensity (L1 / L2 / L3)
3. If L3: Read §0 calibration cases → calibrate review instinct
4. Walk §2 checklist (Code or Spec, based on mode) → mark 🔴/🟡/✅/⬛
5. If Code Mode (L2+): provide at least 1 execution evidence (test output / grep result / schema check / log evidence)
6. Every 🟡 and ✅ → answer §1 four mandatory questions
7. Every 🔴 → §5 self-falsification (L3) or confirm with evidence (L2)
8. Every finding → §6 same-pattern expansion (L2+)
9. Check against §3 six anti-patterns
10. Output report using §8 template
11. Honest disclosure of unverified items
```

**Hard Rules:**

- Reviewer must not be the code author (Maker-Checker separation)
- Any :red_circle: → overall NO-GO, cannot be overridden by "everything else passes"
- PM may embed known bugs as trust test → if missed, entire report credibility is discounted
- "No issues found" is not a valid review conclusion → must state "what I verified" and "what I did not verify"

---

## Customization Guide

### Adding Domain-Specific Calibration Cases

Copy [references/calibration-cases.md](references/calibration-cases.md) and add your own cases following this template:

```markdown
### Case N: [Short Title]
- **AI Said**: [What the AI reviewer claimed]
- **Reality**: [What actually happened]
- **Lesson**: [One-line principle extracted]
```

The best calibration cases come from **real incidents where an AI reviewer was wrong**. Track your own and add them.

### Adding Domain-Specific Checklists

Add items to CL-1 through CL-5 (Code) or CL-S1 through CL-S5 (Spec) that reflect your stack's unique failure modes. Good checklist items:

- Come from a real incident (not hypothetical)
- Have a "typical error" column with a concrete example
- Are mechanically checkable (not "is the code good?")

### Mapping to Your Risk Classification

If you have a severity system (D0-D3, P0-P4, etc.), map it to L1/L2/L3 intensity in the Mode Selection table.
