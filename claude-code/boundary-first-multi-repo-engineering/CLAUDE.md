# LG Workspace — Boundary-First Engineering

## HARD PREREQUISITE — Read Before Any Action

Before ANY planning, editing, or tool use beyond Read/Glob/Grep:

1. **Read** `.claude/boundary-first/decision-gate.md`
2. **Classify** D0/D1/D2/D3 with evidence from the decision tree — not verbally, must cite which branch
3. **Run Preflight** 8 steps from "Step 1: Preflight" below (Classify → Owner → Contract → Security → State → Observability → Validation → Stop conditions)
4. **Read** `.claude/boundary-first/mechanical-verification.md` and state the verification depth level
5. If D1+: **read and fill** `.claude/boundary-first/implementation-plan-template.md`

Violation of this sequence is a **stop condition**. Do not proceed to planning or coding until all steps above are completed and stated explicitly.

## Authority Order

1. Explicit user request
2. Repo-local `CLAUDE.md`, `AGENTS.md`, and task specs
3. Repo-local guards, tests, CI, logging facade, schema contracts
4. This workflow and its adapters

This workflow may tighten behavior but must not contradict a repo-local hard constraint.

## Workflow Stages

```text
1. Classify    → What kind of change is this?
2. Decide      → How much ceremony? (D0-D3)
3. Plan        → Write implementation plan (D1+)
4. Execute     → Make changes, guided by adapter
5. Verify      → Run mechanical verification at matched depth
6. Close out   → Structured summary with evidence
```

## Step 0: Decision Gate

Decision Gate decides **how much ceremony is required**. Preflight (Step 1) decides **what risks and validations apply**.

Before preflight, classify the change severity. Read `.claude/boundary-first/decision-gate.md` for the full decision tree.

- **D0** (local, no protected surface, no information output / new data fields / cross-module / permission-security / SQL mutations, ≤ 3 files): proceed directly to preflight. Step 2b (Query Actual Data) + Evidence Block still required.
- **D1** (single-repo protected surface): confirm assumption, owner, rollback stance. Then preflight.
- **D2** (cross-repo contract): write decision note, producer/consumer impact, validation plan. Then preflight.
- **D3** (auth/HMAC, schema migration, destructive write, permissions): get user confirmation first. Maker-checker required at close-out.

For trivial edits with no protected surface (typo fixes, comment updates, formatting), D0 preflight is sufficient. D0 still requires Step 2b (read source + query actual data) and Evidence Block. Do not over-apply ceremony to changes that carry no boundary, contract, or security risk.

**No source guessing.** If source files, `AGENTS.md`, or nearest tests were not read, do not assume implementation details.

## Step 1: Preflight

Before planning or editing, complete this internally:

1. **Classify**: UI / API / auth / schema / automation / observability / extension-runtime / migration. Highest-risk class drives validation depth.
2. **Owner**: Which repo owns this? Which layer or runtime? Which repo consumes it? Do not start editing until owner and consumer are explicit. Use `.claude/boundary-first/owner-selection.md` when unclear.
3. **Contract**: Does this change request/response shapes, auth headers, canonical strings, schema fields, env bindings, storage keys, or message formats? If yes, inspect both sender and receiver.
4. **Security**: Does this touch HMAC, auth, nonce/timestamp tolerance, secrets, D1/KV/Sheet writes, or extension permissions? If yes, treat as high risk.
5. **State**: Does this change durable state (D1, KV, Sheets, extension storage, persisted config)? If yes, identify rollback path before coding. **Rollback is mandatory for durable changes — no rollback stance means no close-out.**
6. **Observability**: What belongs in normal logs vs `debug_log`? How is `traceId` preserved? Keep debug output off by default.
7. **Validation**: Narrowest test > repo lint/test > `gate:quick` or `gate:pr` > cross-repo validation. Do not stop at lint when the repo has a real gate. Read `.claude/boundary-first/mechanical-verification.md` for the depth ladder and repo-specific gate commands.
8. **Stop conditions**: Pause on auth/HMAC canonical changes, SQL conflict/delete semantics, schema migrations, guard allowlist changes, extension permission expansion, file deletes/moves/broad overwrites without explicit request, or high-risk writes without verification.

## Step 2: Adapter Dispatch

After preflight, load the narrowest adapter that owns the work:

- `lg-proxy-worker`: `.claude/boundary-first/adapters/proxy-worker.md`
- `lg-liff`: `.claude/boundary-first/adapters/liff.md`
- `lg-s5-admin-hub`: `.claude/boundary-first/adapters/s5-admin-hub.md`
- `lg-linebot`: `.claude/boundary-first/adapters/linebot.md`
- `lg-acl-sync`: `.claude/boundary-first/adapters/acl-sync.md`
- `lg-thinq-ext`: `.claude/boundary-first/adapters/chrome-extension.md`

If no dedicated adapter fits, apply the preflight protocol directly and state the assumed system type in close-out.

If the task spans multiple repos, identify the system of record first, then read the consumer-side adapter.
Use `.claude/boundary-first/cross-repo-contracts.md` for producer/consumer alignment.
Use `.claude/boundary-first/conflict-resolution.md` when repo rules conflict.

## Hard Rules

- Put architecture and boundaries before implementation.
- Keep changes controllable, measurable, acceptable, and reviewable.
- Treat auth, HMAC, env, routes, schemas, permissions, and durable writes as protected surfaces.
- Prefer structured logs with `traceId`, event key, and compact metadata.
- Keep `debug_log` off by default and easy to enable only when needed.
- Do not stop at lint or unit tests when the owner repo has stronger mechanical gates.
- **Cross-boundary safety requires both sides.** If a shared contract changes and only one side was validated, the task is not complete.
- **Rollback is mandatory for durable changes.** No rollback/fallback/blast-radius control = no close-out.
- **File safety.** Do not delete, move, rename, or broadly overwrite files just to reduce complexity or silence failing paths. Read `AGENTS.md` and repo-local rules before cleanup or broad rewrites. Treat file deletes, broad moves, and overwrite-heavy rewrites as stop conditions requiring explicit user request.

## Step 2.5: Adversarial Review（PR 前必跑）

gate 通過後、push/PR 前，必須用**獨立 subagent** 對自己的實作跑 adversarial review。

### 為什麼用 subagent

1. **球員兼裁判問題**：同一個 context 寫 code 又 review，會帶著相同假設盲區。subagent 拿到獨立 context，等於換一雙眼睛。
2. **Token 效率**：施工 context 已經很長，review 在獨立 context 跑不佔主對話 token。

### 執行方式

```text
Agent(
  subagent_type: "general-purpose",
  prompt: "你是 adversarial code reviewer。請對以下變更執行完整 adversarial review。
           讀取 .claude/skills/adversarial-code-review/SKILL.md 取得完整審查流程。
           依照 §0-§8 執行，不得跳過任何 phase。
           [變更檔案清單 + 對應的 spec/prompt 路徑]"
)
```

### 規則

- **不得跳過。** gate 驗語法和結構，adversarial review 驗語義和 contract 正確性。兩者互補，缺一不可。
- Review 發現的 **P0/P1 必須修完才能 push**。P2 可記入 residual risk。
- 替換既有功能時，必須先讀被替換的原始碼，抄出關鍵公式和 data flow 當 contract anchor，不能只靠 spec 文字描述。
- 實作完成後，必須拿 prompt 的驗收 checklist 逐條比對，不得靠記憶交差。

## Step 3: Close-Out

Use this template:

```markdown
Decision level: D0 / D1 / D2 / D3
Owner: [repo and layer]
Consumer: [repo or caller affected]
Surfaces touched: [contract / auth / schema / storage / permission]
Validation run: [commands executed and results]
Validation skipped: [commands not run and why]
Rollback stance: [rollback path, fallback, or blast-radius control]
Maker-checker evidence: [n/a for D0/D1, or user confirmation / second review / waiver]
Residual risk: [unknowns or items that need future attention]
```

For D2/D3: confirm that both sides were validated and that maker-checker review was completed or escalated.

If a stop-condition surface was touched and executable verification is unavailable, call out the gap explicitly.

## References

- `.claude/boundary-first/decision-gate.md` — D0-D3 severity classification
- `.claude/boundary-first/implementation-plan-template.md` — required plan format for D1/D2/D3
- `.claude/boundary-first/constitution.md` — founding principles and protected surfaces (SSOT)
- `.claude/boundary-first/owner-selection.md` — repo identification decision tree
- `.claude/boundary-first/cross-repo-contracts.md` — LG contract surfaces
- `.claude/boundary-first/mechanical-verification.md` — gates, guards, GT, contract tests, and verification depth ladder
- `.claude/boundary-first/security-and-gates.md` — HMAC, auth, and validation commands
- `.claude/boundary-first/architecture-and-observability.md` — layers, guards, and logging
- `.claude/boundary-first/validation-matrix.md` — repo-specific gate commands
- `.claude/boundary-first/conflict-resolution.md` — multi-repo conflict strategy
