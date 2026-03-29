# AI Engineering Skills

Community-safe workflow, planning, and review skills for AI coding agents (Claude Code, Codex, ChatGPT, and beyond).

This repository contains three skill packs that cover the full AI-assisted development lifecycle:

```text
  Decide          →        Plan          →       Build        →       Verify
 ┌──────────────┐   ┌──────────────────┐   ┌──────────────┐   ┌──────────────────┐
 │ Boundary-     │   │ Executable Spec  │   │ (your AI     │   │ Adversarial Code │
 │ First         │──>│ Planning         │──>│  agent)      │──>│ Review           │
 │ Engineering   │   │                  │   │              │   │                  │
 └──────────────┘   └──────────────────┘   └──────────────┘   └──────────────────┘
  Who owns this?     What exactly to build?  Code changes       Did the AI get it right?
  What can break?    What are the gates?                        Prove it with evidence.
  How to roll back?  What is NOT in scope?
```

---

## When to Use Which Skill — Decision Tree

```text
You have a task
│
├─ Is it a trivial edit? (typo, comment, formatting)
│  └─ Just do it. No skill needed. (D0)
│
├─ Does it cross a repo, service, or contract boundary?
│  └─ YES → Start with Boundary-First Engineering
│           Identify owner, consumer, contract risk, rollback stance.
│           Then decide if you also need Spec Planning and/or Adversarial Review.
│
├─ Does it need a spec before implementation?
│  (new feature, migration, refactor, multi-phase work)
│  └─ YES → Use Executable Spec Planning
│           Write the spec with Decision Lock, acceptance criteria, scope boundary.
│           Optional: also use Boundary-First if multi-repo.
│
├─ Are you reviewing AI-generated code, a PR, or a spec?
│  └─ YES → Use Adversarial Code Review
│           Select mode (Code / Spec / Release Gate)
│           and intensity (L1 Fast / L2 Standard / L3 Adversarial).
│
└─ Multiple of the above?
   └─ Combine them. Typical full-cycle:
      Boundary-First (decide) → Spec Planning (plan) → AI builds → Adversarial Review (verify)
```

### Common Combinations

| Scenario | Skills to Use | Why |
|----------|--------------|-----|
| Small bug fix, single repo | Adversarial Review (L1 Fast) | Just verify the fix is correct |
| New feature, single repo | Spec Planning → Adversarial Review (L2) | Plan first, verify after |
| Schema migration, multi-repo | Boundary-First → Spec Planning → Adversarial Review (L3) | Full lifecycle |
| Reviewing someone else's PR | Adversarial Review (L2 Code Mode) | Verify with evidence |
| Reviewing a design doc | Adversarial Review (L2 Spec Mode) | Check completeness and consistency |
| Pre-deploy verification | Adversarial Review (L3 Release Gate) | Full execution-layer audit |

---

## End-to-End Example: Full Lifecycle

> Scenario: Add batch inventory query to an API. Touches database schema, cache layer, and a frontend consumer.

### Phase 1: Decide (Boundary-First Engineering)

```text
Prompt: "Use boundary-first to preflight a batch inventory query feature
         that adds a new API endpoint and changes the D1 schema."

Output:
  - Owner: backend-service repo, data layer
  - Consumer: frontend-app repo (calls the new endpoint)
  - Risk: D2 (cross-repo contract + schema change)
  - Protected surfaces: D1 schema, API response shape, cache keys
  - Rollback: schema migration must be backwards-compatible
  - Action: need implementation spec before coding
```

### Phase 2: Plan (Executable Spec Planning)

```text
Prompt: "Write an implementation spec for the batch inventory query.
         Include Decision Lock, acceptance criteria, and rollback per phase."

Output (excerpt):
  - Decision Lock Table:
    | Decision           | Choice              | Owner | Rationale          |
    |--------------------|---------------------|-------|--------------------|
    | Query strategy      | Batch with Promise.all | PM  | Reduces N*4 to U+3 |
    | Cache invalidation  | Versioned key prefix   | PM  | Edge cache TTL issue |

  - Acceptance Criteria:
    ✅ "7 items, 7 unique groups → query count = 10 (U+3)"
    ✅ "Single combo failure does not crash batch"
    ❌ "Performance improves" (rejected: not measurable)

  - Scope Negative List:
    - Do NOT refactor existing single-query path
    - Do NOT change cache TTL values
```

### Phase 3: Build (Your AI Agent)

AI agent implements the spec. Code changes land as a PR.

### Phase 4: Verify (Adversarial Code Review)

```text
Prompt: "Review this PR using adversarial-code-review.
         Mode: Code, Intensity: L3 Adversarial."

Output (excerpt):
  F-01 (🟡): Spec claims "≤4 queries" but code does U+3.
    With 7 unique groups → 10 queries, not 4.
    Verdict: behavior correct, doc inaccurate. Non-blocking.

  F-02 (✅): Fair-share calculation chain traced and verified.
    Manual arithmetic for test scenario matches expected output.

  F-03 (🔴): Share-group query has N+1 pattern without batch.
    7 unique groups → 7 sequential D1 queries.
    Verdict: acceptable at current scale, flag for future optimization.

  Execution Evidence:
    | # | Command                          | Result          |
    |---|----------------------------------|-----------------|
    | 1 | npx vitest run combo.test.ts     | 12/12 PASS      |
    | 2 | grep -rn 'ON CONFLICT' src/      | 3 matches, all parameterized |

  Overall: 🟡 CONDITIONAL-GO (fix doc, accept N+1 for now)
```

### Close-Out

```text
  Decision level: D2
  Owner: backend-service, data layer
  Consumer: frontend-app
  Surfaces touched: D1 schema, API response shape, cache keys
  Validation: gate:pr PASS on backend, build PASS on frontend
  Rollback: schema migration is additive (backwards-compatible)
```

---

## Skill Packs

### 1. Boundary-First Multi-Repo Engineering

A boundary-first engineering workflow for multi-repo, multi-runtime, and contract-sensitive tasks.

- **Codex edition** — `codex/boundary-first-multi-repo-engineering/`
- **Claude Code edition** — `claude-code/boundary-first-multi-repo-engineering/`

**When to use:** Any task that may cross a repo, service, or contract boundary.
**When NOT to use:** Single-file scripts, typo fixes, formatting — anything with zero protected surface.

**Key capabilities:**

- D0-D3 severity classification with decision gate
- Owner / consumer identification and cross-boundary contract model
- Adapter selection (5 types + fallback)
- Mechanical verification depth ladder
- Structured close-out with mandatory rollback stance
- Maker-checker for D2/D3

### 2. Executable Spec Planning

A planning workflow that turns fuzzy requirements into executable specifications — specs that an AI agent can implement without ambiguity, and that can be verified mechanically after implementation.

- **Agent-agnostic** — `executable-spec-planning/` (works with both Claude Code and Codex)

**When to use:** New features, migrations, refactors, or any task handed to an AI agent for execution.
**When NOT to use:** Single-line fixes, doc edits, infra console operations.

**Key capabilities:**

- Architecture Fit Check before writing any spec
- Decision Lock Table with zero-TBD gate
- CONTRACT triple (INPUT + OUTPUT + APPROVAL) for information output tasks
- Scope Negative List to prevent AI scope creep
- Maker-Checker separation with trust calibration
- 25-check completeness guard (Layer A manual + Layer B executable scripts)
- Risk escalation triggers (permission/DB mutations/fan-in/routing/prior incidents)
- Governance audit (7 items) in close-out reports

### 3. Adversarial Code Review

A falsification-first code and spec review skill that forces AI reviewers to prove correctness instead of rubber-stamping "looks good." Distilled from 30+ real incidents where AI reviewers (including Claude, GPT, Codex) gave wrong answers.

- **Agent-agnostic** — `adversarial-code-review/` (works with Claude Code, Codex, ChatGPT, or any LLM)

**When to use:** Any code review, spec review, PR review, or AI output validation.
**When NOT to use:** You trust the output and don't need verification.

**Key capabilities:**

- 8 calibration cases from real AI reviewer failures (not hypothetical)
- Three review modes: Code / Spec / Release Gate
- Three intensity levels: L1 Fast / L2 Standard / L3 Adversarial
- Four mandatory questions per finding (positive evidence, falsification, boundary data, path execution)
- Self-falsification: reviewer must attempt to disprove own findings
- Same-pattern expansion: "where else does this bug exist?"
- 6 anti-patterns that prohibit common AI reviewer shortcuts
- Trust calibration: embed known bugs to test reviewer depth
- Execution evidence table: reviewers must show command output, not just opinions
- Dual checklists: 5 code-focused + 5 spec-focused
- 13 real-world catches documented with before/after comparisons

---

## Quick Start

### Boundary-First Engineering

**Claude Code:** Copy `claude-code/.../CLAUDE.md` to your project root, copy `references/` to `.claude/boundary-first/`. Done — it auto-loads every conversation.

**Codex:** Copy `codex/.../` to `~/.codex/skills/boundary-first-multi-repo-engineering/`, restart Codex.

### Executable Spec Planning

**Claude Code:** Copy `executable-spec-planning/` to `.claude/skills/executable-spec-planning/`, or paste `SKILL.md` content into your project's `CLAUDE.md`.

**Codex:** Copy `executable-spec-planning/` to `~/.codex/skills/executable-spec-planning/`, restart Codex.

### Adversarial Code Review

**Claude Code:** Copy `adversarial-code-review/` to `.claude/skills/adversarial-code-review/`.

**Codex / ChatGPT / any LLM:** Paste `SKILL.md` content at the start of your review conversation.

See [adversarial-code-review/README.md](adversarial-code-review/README.md) for detailed usage guide and examples.

---

## Capability Map

```text
+-- Boundary-First Engineering ---------------------------------+
| Decision Layer     D0-D3 severity classification              |
|                    Implementation plan template                |
|                    Maker-checker for D2/D3                     |
| Boundary Layer     Owner / consumer identification            |
|                    Cross-boundary contract model               |
|                    Conflict resolution                         |
|                    Adapter selection (5 types + fallback)      |
| Verification Layer Mechanical verification depth ladder       |
|                    One-side-only = partial, not pass           |
| Delivery Layer     Structured close-out template              |
|                    Rollback stance mandatory                   |
+---------------------------------------------------------------+

+-- Executable Spec Planning -----------------------------------+
| Pre-Spec Layer     Architecture Fit Check                     |
|                    D0 fast path (skip ceremony if safe)       |
| Spec Layer         Decision Lock Table (zero TBD gate)        |
|                    CONTRACT triple (INPUT+OUTPUT+APPROVAL)     |
|                    Scope Negative List                         |
|                    Phase breakdown with rollback per phase     |
| Review Layer       Maker != Checker separation                |
|                    Trust calibration (embed known defect)      |
|                    R1-R17 review dimensions                    |
| Guard Layer        25-check completeness (Layer A manual)      |
|                    7 executable guard scripts (Layer B)        |
| Close-out Layer    Governance audit (7 items)                  |
|                    Before/After metrics + rejected paths       |
+---------------------------------------------------------------+

+-- Adversarial Code Review -----------------------------------+
| Calibration Layer  8 real AI-reviewer failure cases           |
|                    Pattern matching before review starts      |
| Mode Layer         Code Mode (execution evidence)             |
|                    Spec Mode (logical completeness)            |
|                    Release Gate Mode (both + deploy verify)    |
| Intensity Layer    L1 Fast (low risk, minimal ceremony)       |
|                    L2 Standard (normal feature work)           |
|                    L3 Adversarial (cross-service, auth, schema)|
| Question Layer     Q1 Positive evidence (cite code lines)     |
|                    Q2 Falsification scenario (try to break it) |
|                    Q3 Boundary data (real data, not mock)      |
|                    Q4 Path execution (was fallback exercised?) |
| Guard Layer        6 anti-patterns (prohibited shortcuts)      |
|                    Self-falsification (disprove own findings)   |
|                    Same-pattern expansion (grep for siblings)   |
| Trust Layer        PM can embed known bugs to test reviewer   |
|                    Honest disclosure of unverified items        |
+---------------------------------------------------------------+
```

---

## Real Failure Patterns

All anonymized, no internal details. These are the failure modes these skills were designed to prevent.

### Boundary-First Prevents

**Pattern 1: Payload change = shared contract migration.** Agent updates only the caller; producer rejects; silent drift. Boundary-First finds the real owner and validates both sides.

**Pattern 2: Auth fix = every consumer breaks.** Agent patches one side; entire integration chain fails at deploy. Boundary-First forces dual-side thinking and staged rollout consideration.

**Pattern 3: Bulk action = durable write without rollback.** Agent makes the button work; partial failure corrupts data. Boundary-First escalates to durable-state risk and requires rollback stance.

**Pattern 4: Extension permission = runtime boundary change.** Agent updates manifest, build passes, declared done. Boundary-First classifies as permission surface — build is not sufficient evidence.

### Spec Planning Prevents

**Pattern 5: Wrong architecture, all gates pass.** Team builds NLP chatbot for B2B tool. Zero errors, but users need deterministic menus. Months discarded. Spec Planning checks architecture fit before writing a single line of spec.

**Pattern 6: Fake-complete spec.** Spec has right sections but criteria say "works correctly." Cannot determine PASS/FAIL. Spec Planning's 25-check guard enforces mechanically decidable criteria.

**Pattern 7: AI scope creep.** Agent autonomously "improves" SQL INSERT logic outside spec scope. CI passes (DB mocked). Production breaks. Spec Planning's Negative List + HR-6 prohibit unauthorized mutation changes.

**Pattern 8: Untrustworthy reviewer.** Checker says GO but only checked surface structure. Spec Planning's trust calibration embeds known defects to verify actual review depth.

### Adversarial Review Prevents

**Pattern 9: "All tests pass so it's correct."** Test mock uses lowercase; production stores uppercase. Mock PASS ≠ production PASS. Adversarial Review's Q3 requires real data validation.

**Pattern 10: "Fallback is implemented."** Code only logs warning, no branching. Log exists ≠ handling exists. Adversarial Review's Q4 requires code path evidence.

**Pattern 11: "Cache write = immediate read consistency."** Platform uses eventual consistency; edge cache not invalidated. Adversarial Review's AP-6 prohibits assuming platform behavior.

**Pattern 12: "Hardcoded default = code smell."** Upstream adapter handles it; default is defensive fallback. Adversarial Review's AP-5 requires tracing up and down before concluding.

**Pattern 13: "I checked the linter output."** Reviewer checked warningCount but not errorCount. 3 undefined-variable errors missed. Adversarial Review's Execution Evidence table requires pasting actual command output.

See [adversarial-code-review/examples/real-world-catches.md](adversarial-code-review/examples/real-world-catches.md) for 13 detailed before/after case studies.

---

## 中文說明

### 這個 repo 有三套 skill

**Skill 1: Boundary-First Engineering** — 讓 AI agent 在改 code 之前，先把 owner、boundary、contract、rollback 想清楚。適合多 repo、跨服務、跨 runtime 的工程任務。

**Skill 2: Executable Spec Planning** — 讓 AI 從模糊需求走到可執行規格書（spec），確保每個影響施工的決策都有主人、有紀錄、有驗證方式。適合新功能、遷移、重構、任何要交給 AI agent 執行的任務。

**Skill 3: Adversarial Code Review** — 讓 AI reviewer 用證偽法審查 code 和規格書，而不是表面確認「看起來對」。從 30+ 個 AI reviewer 真實判斷錯誤的案例中提煉出方法論。包含 13 個真實攔截案例的 before/after 對照。

### 什麼時候用哪一套 — 決策樹

```text
你有一個任務
│
├─ 是瑣碎修改？（typo、comment、排版）
│  └─ 直接做，不需要 skill。(D0)
│
├─ 會跨 repo、跨服務、或改到 contract？
│  └─ 是 → 先用 Boundary-First
│         確認 owner、consumer、contract 風險、rollback 策略。
│         再決定是否也需要 Spec Planning 和/或 Adversarial Review。
│
├─ 需要先寫 spec 再施工？
│  （新功能、遷移、重構、多 phase 工作）
│  └─ 是 → 用 Executable Spec Planning
│         寫出有 Decision Lock、驗收標準、scope 邊界的 spec。
│         如果跨 repo，可搭配 Boundary-First。
│
├─ 在審查 AI 產出的 code、PR、或 spec？
│  └─ 是 → 用 Adversarial Code Review
│         選模式（Code / Spec / Release Gate）
│         和強度（L1 Fast / L2 Standard / L3 Adversarial）。
│
└─ 以上都有？
   └─ 組合使用。典型全生命週期：
      Boundary-First (決定) → Spec Planning (規劃) → AI 施工 → Adversarial Review (驗證)
```

### 為什麼需要這三套

因為 AI coding 最昂貴的失敗，不是語法錯誤：

- **Boundary-First 防的是**：owner 判錯、contract 判錯、rollback 沒想、validation 驗錯地方
- **Spec Planning 防的是**：spec 假完整（看起來齊全但驗收條件模糊）、AI 超出 scope 自主決策、架構方向選錯但技術 gate 全過
- **Adversarial Review 防的是**：AI reviewer 橡皮圖章（「看起來對」就 PASS）、mock PASS ≠ production PASS、log 存在 ≠ 處理存在、平台特性假設不驗證

這三套可以獨立使用，也可以組合：先用 Boundary-First 判斷 owner 和風險，用 Spec Planning 寫出可執行的規格書，最後用 Adversarial Review 驗證 AI 的實作。

### 適合誰

- 在多 repo 專案工作的工程師
- 想讓 AI agent 不要一上來就改錯地方的人
- 需要在寫 code 之前先把 spec 想清楚的人
- 想讓 AI review 不只是蓋橡皮圖章的人
- 已經有經驗，但想把 preflight、spec、validation 思路標準化的團隊

### 這不是什麼

- 不是初學者 coding 教學
- 不是框架或 runtime
- 不是萬用 prompt pack
- 不是 repo-local 規則、tests、CI 的替代品

如果你的任務是單檔小腳本、沒有 protected surface、不碰 contract boundary，workflow 會自動分類為 D0，不需要走完整儀式。

### 公開版的設計原則

這個 repository 刻意保留方法論，不帶入任何內部拓樸。

它會教你怎麼想：owner boundary、contract risk、validation depth、rollback stance、decision lock、architecture fit、scope negative list、mechanical verification、falsification-first review。

但不會帶入任何內部 repo 名稱、私有驗證指令、公司流程或內部架構細節。

---

## Repository Structure

```text
skill_shared/
├── README.md                                           <- You are here
├── codex/boundary-first-multi-repo-engineering/        <- Codex edition
├── claude-code/boundary-first-multi-repo-engineering/   <- Claude Code edition
├── executable-spec-planning/                            <- Agent-agnostic planning
│   ├── SKILL.md
│   └── references/
│       ├── spec-template.md
│       └── completeness-guard.md
└── adversarial-code-review/                             <- Agent-agnostic review
    ├── README.md
    ├── SKILL.md
    ├── adversarial-review.md
    ├── references/
    │   └── calibration-cases.md
    └── examples/
        ├── example-code-review.md
        ├── example-spec-review.md
        └── real-world-catches.md
```

---

## License

MIT. Use freely, adapt to your stack, share your calibration cases with the community.
