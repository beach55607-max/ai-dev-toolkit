# {Task Name} — Close-out Report

> **Date**: YYYY-MM-DD
> **Spec Reference**: {link to implementation spec}
> **Duration**: {start date} → {end date}
> **Maker**: {who built it}
> **Claude Review Artifact**: {link or "N/A if Mode B"}
> **Codex Review Artifact**: {link or "BLOCKED(reason)" or "WAIVED_BY_PM(reason)"}
> **Final Authority**: {who approved it}

---

## 1. Executive Summary

{1-3 sentences}

## 2. Scope (Delivered / Not Delivered)

## 3. Timeline

| Date | Event |
|------|-------|

## 4. Deliverables

| # | Artifact | Purpose |
|---|---------|---------|

## 5. Decision Lock Table (Final)

| # | Problem | Decision | Status |
|---|---------|----------|:------:|

## 6. Metrics (Before/After)

| Metric | Before | After | Delta |
|--------|:------:|:-----:|:-----:|

## 7. Known Residuals

| # | Issue | Severity | Ticket | Why Deferred |
|---|-------|:--------:|--------|-------------|

## 8. Lessons Learned

| # | Discovery | Response |
|---|-----------|----------|

## 9. Regression Gate (HR-8)

| # | Bug / Failure Mode | Gate Type | Layer | Verification | Owner |
|---|-------------------|-----------|-------|-------------|-------|
| RG-1 | {bug description} | {test / checklist / guard / monitor / assertion / schema check} | {unit / integration / golden / CONTRACT / lint / runtime} | {verification command or method} | {who maintains} |

> P0/P1, cross-system, auth/DB/schema/repeated incident: missing gate = BLOCKER.
> P2/P3 local bugs: "no gate yet" is allowed, but must state why, temporary control, owner, and remediation date.
> Gate must target the **root cause layer**, not the symptom layer.

**If no gate yet (P2/P3 only):**

| Exemption Reason | Temporary Control | Owner | Remediation Date |
|-----------------|-------------------|-------|-----------------|
| {why no gate now} | {temporary control measure} | {who} | {YYYY-MM-DD} |

---

## 10. Rejected Paths (Optional)

| Path | Why Attempted | Why Rejected | When |
|------|--------------|-------------|------|
| {approach} | {reason} | {what went wrong} | {phase} |

## 11. Traceability Matrix

| Ref Type | Ref ID | Planned In | Verified By | Evidence | Result |
|----------|--------|-----------|-------------|---------|:------:|
| AC | AC-1 | Spec §5 | {command or method} | {evidence source} | ⬜ |
| Gate | Phase-N Gate | Spec §4 | {command or method} | {evidence source} | ⬜ |
| Decision | D-N | Spec §2 | {review method} | {sign-off note} | ⬜ HELD / PASS |
| Regression Gate | RG-N | Close-out §9 | {verification command} | {evidence source} | ⬜ |
| Phase Gate | G[N] | UGP | {PM ACK ref} | {Gate output artifact} | ⬜ PASS / WAIVED |

> Every AC, every Phase Gate, every locked decision, and every Regression Gate must have corresponding verification evidence. Blank row = unverified.

---

## 11.5. Phase Registry (UGP — mandatory)

> See Universal Gate Protocol reference for format definition.

**Entry Point**: {Gate ID} ({PM-directed / Agent-proposed + PM-confirmed})
**Exit Point**: {Gate ID}
**Skipped by PM**: {Gate IDs skipped by PM directive, or "none"}

| Gate | Phase | Status | Evidence | PM ACK |
|------|-------|--------|----------|--------|
| G-1 | Discovery | {PASS / SELF_CERTIFIED(evidence) / BLOCKED / SKIPPED_BY_PM / WAIVED_BY_PM(reason)} | {artifact} | {PM date + decision} |
| G-2 | Concept Critique | {status} | {artifact} | {PM date + decision} |
| G-3 | Canonicalize | {status} | {artifact} | {PM date + decision} |
| G0 | Classify + Preflight | {status} | {artifact} | {PM date + decision} |
| G1 | Architecture Fit | {status} | {artifact} | {PM date + decision} |
| G2 | Spec Lock | {status} | {artifact} | {PM date + decision} |
| G3 | Review Mode | {status} | {artifact} | {PM date + decision} |
| G4 | Implementation | {status} | {artifact} | {PM date + decision} |
| G5 | Adversarial Review | {status} | {artifact} | {PM date + decision} |
| G6 | Close-out | {status} | {artifact} | {PM date + decision} |

> Each Gate must be one of: PASS, SELF_CERTIFIED(evidence), BLOCKED, WAIVED_BY_PM(reason), SKIPPED_BY_PM. SKIPPED, N/A, optional, and blank are prohibited.

---

## 12. Governance Audit

| # | Principle | Status | Evidence |
|---|-----------|:------:|---------|
| GA-1 | Measurable | ⬜ | {numeric thresholds exist} |
| GA-2 | Verifiable | ⬜ | {PASS/FAIL determinable by command} |
| GA-3 | Auditable | ⬜ | {tests re-runnable} |
| GA-4 | CONTRACT | ⬜ | {triple exists and reviewed} |
| GA-5 | Rollback SOP | ⬜ | {steps per Phase with time budget} |
| GA-6 | Kill Switch | ⬜ | {mechanism documented} |
| GA-7 | Cost Cap | ⬜ | {resource bounds stated} |
| GA-8 | Phase Compliance | ⬜ | {Phase Registry complete — all Gates have status + PM ACK, no blanks} |

## 13. Sign-off

| Role | Name/Entity | Date | Status |
|------|------------|------|:------:|
| Maker | {who} | {date} | ⬜ |
| Checker | {who} | {date} | ⬜ |
| Final Authority | {who} | {date} | ⬜ |
