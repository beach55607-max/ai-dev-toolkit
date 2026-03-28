# AI Engineering Skills

Community-safe workflow and planning skills for Codex and Claude Code.

This repository contains two skill packs:

## Skill Packs

### 1. Boundary-First Multi-Repo Engineering

A boundary-first engineering workflow for multi-repo, multi-runtime, and contract-sensitive tasks.

- **Codex edition** — `codex/boundary-first-multi-repo-engineering/`
- **Claude Code edition** — `claude-code/boundary-first-multi-repo-engineering/`

**When to use:** Any task that may cross a repo, service, or contract boundary.
**When NOT to use:** Single-file scripts, typo fixes, formatting — anything with zero protected surface.

### 2. Executable Spec Planning (NEW)

A planning workflow that turns fuzzy requirements into executable specifications — specs that an AI agent can implement without ambiguity, and that can be verified mechanically after implementation.

- **Agent-agnostic** — `executable-spec-planning/` (works with both Claude Code and Codex)

**When to use:** New features, migrations, refactors, or any task handed to an AI agent for execution.
**When NOT to use:** Single-line fixes, doc edits, infra console operations.

**Key capabilities:**

- Architecture Fit Check before writing any spec (prevents building the right thing with the wrong architecture)
- Decision Lock Table with zero-TBD gate
- CONTRACT triple (INPUT + OUTPUT + APPROVAL) for information output tasks
- Scope Negative List to prevent AI scope creep
- Maker-Checker separation with trust calibration
- 25-check completeness guard (Layer A manual + Layer B executable scripts)
- Risk escalation triggers (permission/DB mutations/fan-in/routing/prior incidents)
- Governance audit (7 items) in close-out reports

## Quick Start

### Boundary-First Engineering

**Claude Code:** Copy `claude-code/.../CLAUDE.md` to your project root, copy `references/` to `.claude/boundary-first/`. Done — it auto-loads every conversation.

**Codex:** Copy `codex/.../` to `~/.codex/skills/boundary-first-multi-repo-engineering/`, restart Codex.

### Executable Spec Planning

**Claude Code:** Copy `executable-spec-planning/` to `.claude/skills/executable-spec-planning/`, or paste `SKILL.md` content into your project's `CLAUDE.md`.

**Codex:** Copy `executable-spec-planning/` to `~/.codex/skills/executable-spec-planning/`, restart Codex.

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
```

---

## 中文說明

### 這個 repo 有兩套 skill

**Skill 1: Boundary-First Engineering** — 讓 AI agent 在改 code 之前，先把 owner、boundary、contract、rollback 想清楚。適合多 repo、跨服務、跨 runtime 的工程任務。

**Skill 2: Executable Spec Planning** — 讓 AI 從模糊需求走到可執行規格書（spec），確保每個影響施工的決策都有主人、有紀錄、有驗證方式。適合新功能、遷移、重構、任何要交給 AI agent 執行的任務。

### 為什麼需要這兩套

因為 AI coding 最昂貴的失敗，不是語法錯誤：

- **Boundary-First 防的是**：owner 判錯、contract 判錯、rollback 沒想、validation 驗錯地方
- **Spec Planning 防的是**：spec 假完整（看起來齊全但驗收條件模糊）、AI 超出 scope 自主決策、架構方向選錯但技術 gate 全過

這兩套可以獨立使用，也可以組合：先用 Boundary-First 判斷 owner 和風險，再用 Spec Planning 寫出可執行的規格書。

### 適合誰

- 在多 repo 專案工作的工程師
- 想讓 AI agent 不要一上來就改錯地方的人
- 需要在寫 code 之前先把 spec 想清楚的人
- 已經有經驗，但想把 preflight、spec、validation 思路標準��的團隊

### 這不是什麼

- 不是初學者 coding 教學
- 不是框架或 runtime
- 不是萬用 prompt pack
- 不是 repo-local 規則、tests、CI 的替代品

如果你的任務是單檔小腳本、沒有 protected surface、不碰 contract boundary，workflow 會自動分類為 D0，不需要走完整儀式。

### 真實失敗模式

以下是這兩套 skill 設計來防止的常見失敗，全部匿名化。

#### Boundary-First 防止的失敗

**失敗 1：欄位小改，實際是 shared contract migration。** Agent 只改 caller 端，producer validation 拒收，silent drift 開始。Boundary-First 先找 owner，兩邊一起驗。

**失敗 2：簽章修正，所有 consumer 同時失效。** Agent 只驗一邊，上線時整條整合鏈斷裂。Boundary-First 強制思考哪些 consumer 會一起壞、是否需要 staged rollout。

**失敗 3：admin bulk action，durable write 沒有 rollback。** Agent 覺得按��能按就完成。Boundary-First 把任務升級成資料風險任務，要求先寫 rollback stance。

**失敗 4：extension 多一個權限，runtime boundary change。** Agent 改 manifest、build 過就宣告完成。Boundary-First 標成 permission surface，build 不是充分證據。

#### Spec Planning 防止的失敗

**失敗 5：架構方向選錯，技術 gate 全過。** 團隊投入數月建 NLP chatbot，所有技術指標通過（0 error），但架構假設（使用者會用自然語言描述需求）在 B2B 場景不成立。整條路線廢棄。Spec Planning 在寫 spec 前先做 Architecture Fit Check。

**失敗 6：spec 假完整，驗收條件模糊。** Spec 有所有正確段落，但驗收寫「功能正常」「延遲合理」。施工後無法判定 PASS/FAIL。Spec Planning 的 25-check guard 強制每條驗收條件可機械判定。

**失敗 7：AI 超出 scope 自主修改。** AI agent 在施工時自行「改善」了 scope 外的 SQL INSERT 邏輯，CI 全過（因為測試 mock 了 DB），production 壞掉。Spec Planning 的 Scope Negative List + HR-6 明確禁止未授權的 DB mutation 修改。

**失敗 8：reviewer 深度不足，GO 判定不可信。** Checker 說 PASS，但其實只看了表面結構。Spec Planning 的 trust calibration 在 spec 中埋入已知缺陷，測試 reviewer 是否真的在做深度審查。

### 這個 repo 裡有什麼

#### Boundary-First Engineering

| 版本 | 位置 | 安裝方式 |
|------|------|---------|
| Codex 版 | `codex/boundary-first-multi-repo-engineering/` | 複製到 `~/.codex/skills/`，重啟 Codex |
| Claude Code 版 | `claude-code/boundary-first-multi-repo-engineering/` | `CLAUDE.md` 複製到 project root，`references/` 複製到 `.claude/boundary-first/` |

Claude Code 版多了：Decision Gate (D0-D3)、Implementation Plan Template、Fallback Adapter、Conflict Resolution、Maker-checker 最小證據定義、Close-out 結構化模板。

兩個版本都包含 5 個泛用 adapters：backend service、frontend app、admin console、automation bot、browser extension。

#### Executable Spec Planning

| 版本 | 位置 | 安裝方式 |
|------|------|---------|
| 通用版（agent-agnostic） | `executable-spec-planning/` | Claude Code: 複製到 `.claude/skills/` 或貼入 `CLAUDE.md`；Codex: 複製到 `~/.codex/skills/` |

只有 3 個檔案（SKILL.md + spec-template + completeness-guard），不分平台。

### 怎麼使用

#### Boundary-First — Codex

```text
Use $boundary-first-multi-repo-engineering to do a read-only preflight for a frontend change that may alter a backend request payload. Identify the owner boundary, contract risk, security surface, and required validation.
```

#### Boundary-First — Claude Code

Claude Code 會自動載入 `CLAUDE.md`，不需要顯式呼叫。開始任何工程任務時，workflow 會自動執行 Decision Gate 和 Preflight。

#### Spec Planning — 任意平台

```text
I need to build a new feature that outputs inventory data via API. Use the executable-spec-planning skill to produce a spec with Decision Lock, CONTRACT triple, phase breakdown, and acceptance criteria before we start coding.
```

```text
Write an implementation spec for migrating the user registration flow from the old system to the new one. Include Architecture Fit Check, rollback SOP per phase, and run the completeness guard before sending to Checker.
```

### 公開版的設計原則

這個 repository 刻意保留方法論，不帶入任何內部拓樸。

它會教你怎麼想：owner boundary、contract risk、validation depth、rollback stance、decision lock、architecture fit、scope negative list、mechanical verification。

但不會帶入任何內部 repo 名稱、私有驗證指令、公司流程或內部架構細節。

---

## English

### What This Is

Two engineering skills for AI coding agents:

**Skill 1: Boundary-First Engineering** — helps agents identify ownership, contract boundaries, and validation depth before changing code. For multi-repo, multi-runtime, and contract-sensitive tasks.

**Skill 2: Executable Spec Planning** — helps agents and humans go from fuzzy requirements to executable specifications, ensuring every implementation-affecting decision has an owner, rationale, and verification method. For new features, migrations, refactors, and any task handed to an AI for execution.

### Why Two Skills

Because the most expensive AI coding failures aren't syntax errors:

- **Boundary-First prevents**: wrong owner, missed contracts, forgotten rollback, wrong-side validation
- **Spec Planning prevents**: fake-complete specs, AI scope creep, wrong architecture with passing gates, untrustworthy reviewer verdicts

They work independently or together: use Boundary-First to identify owner and risk, then Spec Planning to produce an executable spec.

### Who This Is For

- Engineers in multi-repo projects
- People who want AI agents to think before editing
- Teams that need specs verified mechanically, not just "looks good"
- Engineers who want standardized preflight, spec, and validation thinking

### What This Is Not

- Not a beginner coding tutorial
- Not a framework or runtime
- Not a generic prompt pack
- Not a substitute for repo-local rules, tests, or CI

If your task is a single-file script with no protected surface, the workflow classifies it as D0 and requires minimal ceremony.

### Real Failure Patterns

All anonymized, no internal details.

#### Boundary-First Prevents

**Pattern 1: Payload change = shared contract migration.** Agent updates only the caller; producer rejects; silent drift. Boundary-First finds the real owner and validates both sides.

**Pattern 2: Auth fix = every consumer breaks.** Agent patches one side; entire integration chain fails at deploy. Boundary-First forces dual-side thinking and staged rollout consideration.

**Pattern 3: Bulk action = durable write without rollback.** Agent makes the button work; partial failure corrupts data. Boundary-First escalates to durable-state risk and requires rollback stance.

**Pattern 4: Extension permission = runtime boundary change.** Agent updates manifest, build passes, declared done. Boundary-First classifies as permission surface — build is not sufficient evidence.

#### Spec Planning Prevents

**Pattern 5: Wrong architecture, all gates pass.** Team builds NLP chatbot for B2B tool. Zero errors, but users need deterministic menus. Months discarded. Spec Planning checks architecture fit before writing a single line of spec.

**Pattern 6: Fake-complete spec.** Spec has right sections but criteria say "works correctly." Cannot determine PASS/FAIL. Spec Planning's 25-check guard enforces mechanically decidable criteria.

**Pattern 7: AI scope creep.** Agent autonomously "improves" SQL INSERT logic outside spec scope. CI passes (DB mocked). Production breaks. Spec Planning's Negative List + HR-6 prohibit unauthorized mutation changes.

**Pattern 8: Untrustworthy reviewer.** Checker says GO but only checked surface structure. Spec Planning's trust calibration embeds known defects to verify actual review depth.

### What Is In This Repository

#### Boundary-First Engineering

| Edition | Location | Install |
|---------|----------|---------|
| Codex | `codex/boundary-first-multi-repo-engineering/` | Copy to `~/.codex/skills/`, restart Codex |
| Claude Code | `claude-code/boundary-first-multi-repo-engineering/` | Copy `CLAUDE.md` to project root, `references/` to `.claude/boundary-first/` |

Claude Code edition adds: Decision Gate (D0-D3), Implementation Plan Template, Fallback Adapter, Conflict Resolution, Maker-checker evidence definition, Structured close-out.

Both editions share 5 generic adapters: backend service, frontend app, admin console, automation bot, browser extension.

#### Executable Spec Planning

| Edition | Location | Install |
|---------|----------|---------|
| Agent-agnostic | `executable-spec-planning/` | Claude Code: copy to `.claude/skills/` or paste into `CLAUDE.md`. Codex: copy to `~/.codex/skills/` |

3 files only (SKILL.md + spec template + completeness guard). No platform split needed.

### Example Prompts

#### Boundary-First

```text
Use $boundary-first-multi-repo-engineering to do a read-only preflight for a frontend change that may alter a backend request payload.
```

Claude Code auto-loads `CLAUDE.md` — no explicit invocation needed.

#### Spec Planning

```text
I need to build a new feature that outputs inventory data via API. Use the executable-spec-planning skill to produce a spec with Decision Lock, CONTRACT triple, phase breakdown, and acceptance criteria.
```

```text
Write an implementation spec for migrating user registration. Include Architecture Fit Check, rollback SOP per phase, and run the completeness guard before Checker review.
```

### Public-Safe Design

This repository keeps the method, not the internal topology:

- owner boundaries, contract risk, validation depth, rollback stance, decision lock, architecture fit, scope negative list, mechanical verification

It intentionally avoids: company-specific repo names, internal architecture details, private validation commands, organization-specific processes.

### Repository Structure

```
skill_shared/
├── README.md
├── codex/boundary-first-multi-repo-engineering/       <- Codex edition
├── claude-code/boundary-first-multi-repo-engineering/  <- Claude Code edition
└── executable-spec-planning/                           <- Agent-agnostic planning
    ├── SKILL.md
    └── references/
        ├── spec-template.md
        └── completeness-guard.md
```
