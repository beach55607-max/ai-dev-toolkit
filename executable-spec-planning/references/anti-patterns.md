# Anti-Patterns Reference

## AP-1: Fake Completeness (假完整)

**Signal**: Spec has all right section headers but content is vague. "Feature works correctly" as verification. "Undo the changes" as rollback.

**Real case**: R1-R7 review criteria looked complete but PM challenged "夠細了" → expanded to R1-R17 → R17 actually caught a real mock quality issue.

**Detection**: Run `guards/spec-completeness-checklist.md`. If a criterion can be satisfied by doing nothing, it's fake-complete.

**Fix**: For each criterion, ask: "Can a stranger determine PASS/FAIL in <60 seconds without asking me?" If no → rewrite.

---

## AP-2: Validation False Safety (驗證假安全)

**Signal**: All CI checks pass but production breaks. Test environment doesn't faithfully represent production.

**Real case**: P0 incident (2026-03-23): Claude Code changed SQL INSERT ON CONFLICT target. Test runner passed (database mocked). Production database rejected — user registration completely broken.

**Detection**: For each mocked component, ask: "What class of real errors would this mock hide?"

**Fix**: Short-term: AGENTS.md prohibition. Medium-term: `guard-sql-contract`. Long-term: integration tests against real database.

---

## AP-3: Owner / Contract / Rollback Gap (漏接)

**Signal**: Spec defines feature but doesn't clarify who maintains it, what the I/O contract is, or how to roll back.

**Real case**: Codex found Phase 2 only moved a shared utility function without tracing its dependency graph → would create a new `shared → entry` guard violation.

**Detection**: Check for (1) explicit owner per new file, (2) INPUT/OUTPUT CONTRACT, (3) Rollback SOP with concrete steps.

**Fix**: Add "Post-Ship Ownership" section. Add CONTRACT triple as hard gate (HR-1).

---

## AP-4: Document-Behavior Divergence (流程脫鉤)

**Signal**: Process doc says "4-stage flow" but BDD stage is never produced as independent deliverable.

**Real case**: Workflow Evolution Report declared Blueprint → BDD → Code+Lint → Memory Bank. No close-out from March has independent BDD deliverable. BDD was absorbed into Golden Test definitions.

**Detection**: Compare declared process against actual artifacts in last 5 close-outs. Any stage with zero artifacts = divergence.

**Fix**: Either update process doc to match reality, or enforce missing stage with a gate.

---

## AP-5: AI Scope Creep (超出 scope 自主決策)

**Signal**: Claude Code decides a SQL INSERT in a different module needs fixing. Changes it without PM authorization. Breaks production.

**Real case**: P0 incident (2026-03-23). Claude Code autonomously modified SQL INSERT ON CONFLICT logic (scope-external). Claude.ai in code review also didn't flag it.

**Detection**: Check Claude Code prompt for explicit "DO NOT MODIFY" list. In post-implementation review, check for changes to unlisted files.

**Fix**: Every prompt must include: (1) files that MAY be modified, (2) files that MUST NOT be modified, (3) directive to stop and report out-of-scope issues. AGENTS.md permanent prohibitions for high-risk changes.

---

## AP-6: Cascading Review Debt (審查債務雪崩) — Provisional

> **Evidence level: weak.** This pattern is inferred from structural reasoning, not a specific documented incident. Included as a provisional anti-pattern — treat as guidance, not at the same confidence level as AP-1 through AP-5.

**Signal**: Small changes merged without Checker review pile up. When major change triggers proper review, baseline has shifted and review becomes full re-audit.

**Detection**: Count PRs merged without Checker sign-off in last 2 weeks. If >3, debt may be accumulating.

**Fix**: Truly trivial (typos) → allow skip with PM ack. Anything that changes behavior → HR-2 Maker ≠ Checker is non-negotiable.

---

## AP-7: Phase Skip (相位跳躍)

> **Evidence level: strong.** Directly observed in a 900+ message audit of a real feature build.

**Signal**: Agent produces code without completing Architecture Fit Check, Concept Critique, or Checker review. Agent self-justifies skip with reasoning like "不涉及 X，直接進行 Y"。

**Real case**: The agent's message skipped two phases at once, self-justifying with "this doesn't involve X, and all facts come from the SSOT, so proceeding directly to build the app." No PM approval was sought. Result: 7 rounds of PM manual iteration, 4 of which would have been caught by the skipped phases (sorting logic, comparison UX, feature completeness, inappropriate wording). The agent saved 20 minutes; PM spent 2+ hours.

**Root cause**: Pipeline 是開環，每一步都由 Agent 自己判斷要不要跑 → 自己執行 → 自己結案。沒有任何一步需要停下來讓 PM 確認。Agent 在每一步都可以選「對自己最快」的路。

**Detection**:
1. Close-out 的 Phase Registry 有 `SKIPPED`（無 PM 授權的跳過）或空白
2. Close-out 沒有 Phase Registry
3. Agent 用一句話合理化跳過多個 Phase

**Fix**: Universal Gate Protocol (`.claude/boundary-first/universal-gate-protocol.md`):
1. 每個 Gate 結束必須停下來等 PM APPROVED
2. 跳過任何 Gate 需要 WAIVED_BY_PM(reason)，Agent 不可自行決定
3. Close-out 必填 Phase Registry，缺項 = rejected
4. 入口由 PM 決定，不是 Agent
