# Full Review Pipeline

> 完整審查流程：Claude 對抗性審查 → Codex 獨立審查 → 彙整修復
> Required input: $ARGUMENTS（變更檔案清單、PR 號碼、或 spec 路徑）
> If $ARGUMENTS is empty, use `git diff --name-only` to auto-detect changed files.

## 流程

你必須**嚴格按照以下 7 個 Phase 依序執行**（1 → 2 → 2.5 → 3 → 4 → 4.5 → 5），不得跳過任何步驟。Phase 2.5/4.5 是 mandatory subphase，不是可選。

---

### Phase 1: 收集變更範圍

1. 如果 `$ARGUMENTS` 為空，執行 `git diff --name-only` 和 `git diff --cached --name-only` 取得變更檔案清單
2. 列出所有變更檔案，確認審查範圍
3. 讀取所有變更檔案的內容

---

### Phase 2: Claude 對抗性審查 + 程式碼審查

用 **Agent tool** 起獨立 subagent，執行完整的 adversarial code review。

```
Agent(
  subagent_type: "general-purpose",
  prompt: "你是 adversarial code reviewer。
           請對以下變更執行完整 adversarial review。
           讀取 .claude/skills/adversarial-code-review/SKILL.md 取得完整審查流程。
           依照 §0-§8 執行，不得跳過任何 phase。
           同時執行程式碼品質審查：可讀性、效能、安全性、錯誤處理。

           審查目標檔案：[變更檔案清單]

           輸出格式必須包含：
           1. 每個 finding 的等級（🔴/🟡/✅）
           2. 具體檔案路徑 + 行號
           3. 建議修復方案
           4. Reviewer 誠實揭露（沒驗證的部分）"
)
```

等待 subagent 回傳結果，保存為 **Claude Review Report**。

---

### Phase 2.5: Runtime Spot Check

> Spec/文件變更也需要 E1 evidence。至少 3 個可重跑的機械驗證。

在 Phase 3 之前，對變更檔案執行 runtime 驗證：

1. **至少 3 個 E1 evidence**（可重跑的指令輸出），例如：
   - `grep -c '<pattern>' <file>` 確認關鍵規則存在
   - `wc -l <file>` 確認檔案長度合理
   - `diff <SSOT> <copy>` 確認同步結果
   - `npm test` / test runner 測試輸出
   - `curl` API 呼叫結果

2. **記錄格式**：
```markdown
## Runtime Spot Check (E1 Evidence)
| # | Command | Expected | Actual | PASS/FAIL |
|---|---------|----------|--------|-----------|
| 1 | `grep -c 'closed set' ugp.md` | ≥1 | 2 | PASS |
| 2 | `npm test` | 0 failures | 0 failures | PASS |
| 3 | `diff ssot copy` | 0 lines | 0 lines | PASS |
```

3. **E1 不足 = BLOCKED。** 如果無法產出 3 個 E1，記錄原因並報告 PM。

---

### Phase 3: Codex 獨立審查

用 Bash 呼叫 Codex CLI 對同一批檔案做獨立審查。

執行指令：
```bash
codex exec -c 'approval_policy="on-failure"' -o /tmp/codex-review-output.md "你是獨立的 code reviewer。
請讀取 .claude/skills/adversarial-code-review/SKILL.md 取得完整審查流程。
依照 §0-§8 執行，與 Phase 2 Claude 審查等強度。

請對以下檔案執行：
1. 對抗性審查：找出潛在 bug、邏輯漏洞、邊界條件遺漏
2. 程式碼品質審查：可讀性、效能、安全性、錯誤處理
3. 每個 finding 標記嚴重度（P0 critical / P1 major / P2 minor）
4. 附上具體檔案路徑和行號
5. Reviewer 誠實揭露（沒驗證的部分）

審查檔案：[變更檔案清單]"
```

保存結果為 **Codex Review Report**。

#### Codex 不可用時（fail-closed）

**如果 Codex CLI 失敗、不可用、或回傳空結果：**

1. 記錄失敗原因
2. **BLOCKED** — 停下來通知使用者：「Codex review 不可用。原因：[X]」
3. 使用者決定：
   - (a) 以 Claude 單路審查繼續 + 承認信度降低 → 記錄為 `WAIVED_BY_PM(reason)`
   - (b) 修復 Codex 環境後重跑
4. 在 review report 的 Codex Status 欄位記錄使用者決定

**禁止靜默跳過 Phase 3。** Codex 缺席但未通知使用者 = 違反 UGP-5（fail-closed）。

---

### Phase 4: 彙整 + 修復

1. **並排比較** Claude 和 Codex 的 findings：
   - 兩邊都找到的 = 高信度問題，**必須修**
   - 只有一邊找到的 = 需要判斷，交叉驗證後決定
   - 互相矛盾的 = 列出雙方論點，由使用者決定

2. **產出彙整報告**，格式如下：

```markdown
# Full Review Report

## 審查範圍
- 變更檔案：[清單]

## 共識問題（Claude + Codex 都找到）
| # | 嚴重度 | 位置 | 問題描述 | 修復方案 |
|---|--------|------|---------|---------|

## Claude 獨有 Findings
| # | 嚴重度 | 位置 | 問題描述 | 交叉驗證結果 |
|---|--------|------|---------|-------------|

## Codex 獨有 Findings
| # | 嚴重度 | 位置 | 問題描述 | 交叉驗證結果 |
|---|--------|------|---------|-------------|

## 矛盾項（需使用者決定）
[如有]

## 修復清單
- [ ] ...
```

3. **詢問使用者**：是否同意修復清單？確認後開始逐項修復。

4. 修復完成後，進入 Phase 4.5。

---

### Phase 4.5: Gemini Gate

> 獨立 AI Gate 判斷 evidence 鏈是否完整。D2 建議 / D3 強制。

1. **準備 Gate Input**: 將 Phase 2 Claude Report + Phase 2.5 Runtime Evidence + Phase 3 Codex Report + Phase 4 彙整報告合併為一份 review report。

2. **呼叫 Gemini Gate**（如有 `scripts/gate-gemini.sh`，直接呼叫；否則手動提交 Gemini 審查）。

3. **判讀結果**:
   - `{"verdict":"PASS"}` → 繼續 Phase 5
   - `{"verdict":"REJECT","reasons":[...]}` → 檢視 reasons，修復後重跑 Phase 4.5
   - API 失敗 → BLOCKED → PM 決定

4. **D-level 啟用規則**:
   - **D0/D1**: Gemini Gate 不需要（跳過此 Phase，記錄「D-level 不要求」）
   - **D2**: Gemini Gate 建議執行。未執行需 PM ACK
   - **D3**: **Gemini Gate 強制。** 未執行 = BLOCKED，不可繼續

5. 通過後進入 Phase 5。

---

### Phase 5: 修復 Diff 回歸掃描

> 研究依據：Linux kernel ~50% 的 bug 是 fix-induced regression（改 A 壞 B）。
> 修復本身沒人審 = 最大盲區。此 phase 成本低（只掃 diff），但堵住最關鍵的漏洞。

1. 執行 `git diff` 取得 **Phase 4 修復產生的 diff**（不是原始變更，是修復的改動）

2. 用 Codex 快速掃描修復 diff：
```bash
codex exec -c 'approval_policy="on-failure"' "你是 regression 檢查員。以下是一批 bug 修復的 diff。
只檢查這些修復本身有沒有引入新問題：
- 改了 A 會不會壞 B？
- 有沒有遺漏的 else branch / return path？
- null/undefined 處理是否完整？
- 原本正常的呼叫者會不會因為這次改動收到不同的回傳值？

只回報修復引入的問題，不要重複之前已知的 findings。

修復 Diff：
$(git diff)"
```

3. 如果 Phase 5 找到新問題 → 修復 → 再跑一次 Phase 5（最多循環 2 次，防止無限迴圈）

4. **Phase 5 產生新 diff 且 D2/D3 → 必須重跑 Phase 4.5 Gemini Gate。** Phase 4.5 的 PASS 只對當時的狀態背書，後續修復如果改動 substantial，Gate 需重新判斷。

5. 最後跑測試（如有 test）確認無 regression。

---

## 規則

- Phase 2 和 Phase 3 可以**平行執行**（用 Agent + Bash 同時發出）
- 任何 🔴 P0/P1 問題必須修完才算流程結束
- P2 可記入 residual risk，不強制修復
- Phase 5 最多循環 2 次（Phase 4 修復 → Phase 5 掃描 → 再修 → 再掃一次 → 結束）
- 最終必須 test 通過才算流程完成
