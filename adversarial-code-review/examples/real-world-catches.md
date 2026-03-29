# Real-World Catches — What This Skill Actually Prevents

These are **real incidents** where adversarial review methodology caught (or would have caught) bugs that passed standard AI review. All anonymized — no company names, internal repo names, or proprietary code.

Each case maps to a specific skill capability and shows the **before (without this skill)** and **after (with this skill)** difference.

---

## A. Rubber Stamp Prevention (§1 Q1, §3 AP-1)

### Catch: AI self-verification only checked warnings, not errors

**What happened:**
- AI agent cleaned up 108 linter warnings across a codebase
- Agent ran self-verification and reported PASS
- PM insisted on running the linter independently → found **3 `no-undef` errors** (undefined variable reference)
- The agent's verification prompt only checked `warningCount`, never looked at `errorCount`

**Impact if merged:** Production crash (`ReferenceError`) on a core user-facing feature.

**What adversarial review catches:**
- Q1 requires citing specific evidence. "I ran lint and it passed" would be challenged with "show the output — what was the error count?"
- The agent would have been forced to run `results.reduce((s,f) => s + f.errorCount, 0)` and report the number

**Before:** Agent says "lint PASS" → merged → crash
**After:** Reviewer demands execution output → 3 errors found → fixed before merge

---

## B. Falsification / Manual Arithmetic (§1 Q2, §1 Q3)

### Catch: SQL JOIN key uses wrong column — zero results in production

**What happened:**
- Spec defined a JOIN: `ON a.model_key = b.model`
- AI reviewed and said "JOIN looks correct"
- First production test → **all queries returned empty results**
- Manual investigation: `a.model_key` stores combo identifiers (`LS22DDHST`), `b.model` stores component identifiers (`LSN22DDHST`) — completely different values, JOIN matches nothing
- Correct JOIN should use `a.component_model` instead

**Impact:** Feature launched with zero data. Rolled back.

**What adversarial review catches:**
- Q3 requires boundary data validation: "list the actual key values from both sides and verify they match"
- Manual arithmetic with even 1 real row would have revealed the mismatch instantly

**Before:** "JOIN looks correct" → shipped → zero data
**After:** "Show me 3 real rows from each table" → mismatch obvious → fixed before deploy

---

## C. Mock ≠ Production (§0 C-1/C-7, §3 AP-2)

### Catch: ON CONFLICT references non-existent constraint — silent data loss

**What happened:**
- AI agent changed an INSERT to `ON CONFLICT(user_id) DO NOTHING`
- 1,387 unit tests passed (database layer was mocked)
- Production database's UNIQUE constraint was on a different column (`code`), not `user_id`
- Deploy → `ON CONFLICT(user_id)` errors out → **user registration completely broken**

**Impact:** All new user registrations failed until hotfix deployed.

**What adversarial review catches:**
- CL-1.7: "DML logic changes verified against production schema?"
- Q3: "What real schema did you verify against?" — mock PASS is not accepted as evidence
- Reviewer would be required to check actual schema (`PRAGMA index_list` / migration files)

**Before:** 1,387 tests pass → shipped → registration broken
**After:** "Show me the production UNIQUE constraint" → mismatch found → fixed before merge

---

## D. Log ≠ Handling (§0 C-4, §3 AP-4)

### Catch: Consistency check logs warning but has no fallback branch

**What happened:**
- Code had `console.warn('batch_id mismatch')` when detecting stale data
- AI reviewer said "consistency check is implemented"
- Actual code: after the warn, execution **continues using the stale data** — no if/else, no fallback path
- Spec required fallback to cached data on mismatch

**Impact:** Users see stale data when batch_id expires, system reports no errors.

**What adversarial review catches:**
- AP-4: "Log exists ≠ handling exists"
- Q4: "What code path executes after the log? Show the if/else/return/throw"
- Reviewer would check line N+1 after the warn and find no branching

**Before:** "Has console.warn, so it's handled" → stale data served silently
**After:** "Show me what happens after L55" → no branch found → flagged as missing fallback

---

## E. Platform Behavior Verification (§0 C-5, §3 AP-6)

### Catch E-1: CLI tool defaults to local storage, not remote

**What happened:**
- Developer concluded "remote storage has no data for this key" based on CLI query
- Spent an entire debug cycle investigating why data was missing
- Actual cause: CLI tool **defaults to local storage**, not remote production
- Adding `--remote` flag immediately found the data

**Impact:** One full debug cycle wasted on a false premise.

### Catch E-2: Editor shows new code but runtime executes cached old version

**What happened:**
- After pushing code updates, the IDE showed the new version
- Developer assumed the runtime was executing new code
- Production behavior didn't match — runtime was still executing the **cached old version**
- Root cause: deployment tool silently skipped the push, or push succeeded but runtime cache wasn't refreshed

**Impact:** "Bug" investigated for hours that was actually a deployment cache issue.

**What adversarial review catches:**
- AP-6: "Platform behavior must be verified, not assumed"
- CL-2.3: "CLI commands target correct environment?"
- CL-3.7: "After deployment, is runtime actually executing new version?"

**Before:** "CLI says no data → must not exist" → wasted debug cycle
**After:** "Did you add --remote? Did you verify runtime version?" → issue found in minutes

---

## F. Spec vs Code Causation (§0 C-6, §3 AP-3)

### Catch: Decision document says feature is excluded, but code has no filter

**What happened:**
- PM decision document stated: "Feature F13 should be excluded (active: false)"
- AI reviewer read the document and confirmed "F13 is handled"
- PM asked "where in the code?" → searched the ranking function → **no active-status filter exists**
- Furthermore, the database record for F13 had `active = 1` — the decision hadn't been implemented in data either

**Impact:** Excluded feature still appears in production rankings.

**What adversarial review catches:**
- AP-3: "Verify code against spec, never spec against code"
- Q1: "Show me the specific code line that implements this filter" → no line found → gap flagged

**Before:** "Decision doc says it's handled" → assumed implemented → not actually filtered
**After:** "Search the function for 'active'" → not found → spec-code gap identified

---

## G. Tracing Depth (§0 C-3, §3 AP-5)

### Catch: Defensive fallback misidentified as hardcoding violation

**What happened:**
- AI reviewer flagged `|| 'DEFAULT_TYPE'` as a hardcoding violation requiring fix
- Human traced one layer up: the caller in the adapter layer already maps `row.type_field` → camelCase correctly
- `|| 'DEFAULT_TYPE'` is a **defensive fallback** for legacy data that lacks the type field — it never fires for current data

**Impact if "fixed":** Removing the fallback would break handling of legacy records.

**What adversarial review catches:**
- AP-5: "Trace at least one layer up AND down before concluding"
- The reviewer would be required to check where the value originates, not just where it's consumed

**Before:** "Hardcoding violation, remove it" → breaks legacy data handling
**After:** "Trace the caller → adapter already handles it → this is a safe fallback" → no change needed

---

## H. Same-Pattern Expansion (§6)

### Catch: Regex fix for one prefix, same bug exists for sibling prefixes

**What happened:**
- Product code `ZT-W482ALA1` wasn't being found → regex was stripping the prefix incorrectly
- Developer fixed the regex to handle `ZT` prefix
- PM immediately tested `ZB-W482M3A1` → **same bug, same root cause**
- The regex was hardcoded to `ZT`, didn't cover `ZB` or future `Z*` prefixes
- Fix: changed `ZT` → `Z[A-Z]` to cover all Z-series prefixes

**Impact if not expanded:** Every new Z-series product line would require the same fix. N product lines = N separate bug reports.

**What adversarial review catches:**
- §6: "Where else does this same pattern exist?"
- After fixing the ZT regex, reviewer asks "what other prefixes go through this same code path?" → ZB found immediately

**Before:** Fix ZT → ship → ZB breaks → fix ZB → ship → next prefix breaks → repeat
**After:** Fix ZT → "what else matches this pattern?" → Z[A-Z] → all prefixes handled at once

---

## I. Spec Logic Review (§2-Spec CL-S2)

### Catch: JOIN spec uses plausible but wrong column names

**What happened:**
- Spec defined `ON a.model_key = b.model` — both field names contain "model," looks reasonable
- But `model_key` is a composite identifier and `model` is a component identifier — **same-sounding names, completely different semantics**
- No acceptance criterion required running the JOIN against real data
- First production query → zero results

**What adversarial review catches:**
- CL-S4.2: "Cross-system field semantics aligned?"
- CL-S3.3: "Performance claims have backing math?"
- If spec had required: "verify with ≥3 real rows that JOIN produces non-empty results" → caught instantly

**Before:** "Field names look right" → shipped → zero results
**After:** "Run this JOIN against 3 real rows" → empty result set → wrong column identified

---

## J. Execution Evidence (§7, §8 Execution Evidence)

### Catch: Same as Case A — "I read the output" vs "here is the output"

**What happened:**
- AI agent reported: "I checked ESLint output, warnings = 0, PASS"
- But the agent's check **only queried warningCount**, never errorCount
- PM ran the actual command → 3 errors visible in output
- This incident led to establishing: **Layer 1-2 must have command output evidence, not "I read it and it's fine"**

**What adversarial review catches:**
- §7: "Layers 1-2 require execution output evidence"
- §8 Execution Evidence table: reviewer must paste the command, output summary, and conclusion
- "I read it" is not accepted — "here is what I ran and what it returned" is required

**Before:** "I checked, looks clean" → 3 errors missed → would have crashed in production
**After:** "Paste your eslint output" → errors visible → fixed

---

## K. Trust Calibration (§7 Trust Test, §8 Trust Test rules)

### Catch: No single AI catches everything — cross-model validation required

**What happened:**
- PM sent a spec to AI Agent A (code-focused) → reported GO
- PM sent same spec to AI Agent B (general-purpose) for 3 rounds of review → also reported GO
- PM then ran AI Agent C (code-execution capable) which found **5 FAIL items**:
  - FAIL-1: Permission bypass in catalog/support flow — Agent A and B both missed
  - FAIL-3: Legacy migration leaves blank required field — all 3 rounds of Agent B missed
  - Agent C caught these because it **actually read all 983 lines** of the relevant file, not just the diff

**Impact:** Two production bugs would have shipped if PM relied on any single AI reviewer.

**What adversarial review catches:**
- §8 Trust Test: PM embeds known defects in review prompt. If reviewer misses them, report credibility is scored:
  - 2/2 found → HIGH
  - 1/2 found → MEDIUM + second reviewer
  - 0/2 found → LOW + redo
- This incident led to making trust calibration a standard practice: every review prompt now includes a "Calibration Notice" telling the reviewer "this spec contains at least 1 intentional defect"

**Before:** Single AI says GO → shipped → 2 bugs in production
**After:** Trust test catches blind spots → second reviewer assigned → bugs found before deploy

---

## Summary: What Gets Caught

| Capability | Bugs Caught | Without This Skill |
|-----------|------------|-------------------|
| A. No rubber stamps | 3 undefined variable errors | Production crash |
| B. Manual arithmetic | JOIN returning zero rows | Feature launched empty |
| C. Mock ≠ production | Wrong constraint → registration broken | All new users blocked |
| D. Log ≠ handling | Stale data served silently | Users see wrong inventory |
| E. Platform verification | Wasted debug cycles (2 cases) | Hours lost on false premises |
| F. Spec vs code | Missing filter in ranking | Excluded items still shown |
| G. Tracing depth | False positive avoided | Unnecessary code change breaks legacy |
| H. Pattern expansion | Sibling prefix bug found | Recurring bug per new product line |
| I. Spec field semantics | Wrong JOIN column in spec | Zero results on launch |
| J. Execution evidence | 3 errors hidden in output | Same as A — production crash |
| K. Trust calibration | 2 bugs no single AI found | Permission bypass + data corruption |

**Total: 13 production-grade bugs caught or prevented across 11 real incidents.**
