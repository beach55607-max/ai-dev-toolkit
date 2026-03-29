# Example: Spec Review — Batch Query Optimization

## Review Request

```
Mode: Spec
Intensity: L2 Standard
Target: "Batch Query Optimization Spec v1" §3-§5
```

### Spec Under Review (excerpts)

> **§3 Design**: The new batch query reduces database round-trips from N*4 to at most 4 queries for any number of input items.
>
> **§4 Implementation**: Step 1: Fetch model index (1 query). Step 2: For each unique group, fetch group members (1 query each). Step 3: Fetch inventory batch (1 query). Step 4: Fetch supply dates (1 query).
>
> **§5 Acceptance**: Performance improves significantly. All existing tests continue to pass.

---

## Example Review Output

# Adversarial Code Review Report

## Meta
- **Reviewer**: ChatGPT
- **Target**: Batch Query Optimization Spec v1, §3-§5
- **Date**: 2026-03-29
- **Mode**: Spec
- **Intensity**: L2 Standard
- **Overall**: 🟡 CONDITIONAL-GO

## Findings

### [F-01] §3 claim "at most 4 queries" contradicts §4 implementation
- **Level**: 🔴
- **Location**: `spec §3` vs `spec §4`
- **Description**: §3 claims "at most 4 queries for any number of input items." §4 Step 2 says "for each unique group, fetch group members (1 query each)." If there are U unique groups, total queries = 1 + U + 1 + 1 = U + 3. The claim "at most 4" is only true when U = 1.
- **Q1 Positive Evidence**: §4 explicitly describes a per-group query in Step 2.
- **Q2 Falsification**: With 7 input items having 7 unique groups → 10 queries, not 4. With 3 items sharing 1 group → 4 queries (claim holds). The claim is conditional, not universal.
- **Q3 Data Validation**: Manual arithmetic: 7 items × 7 groups = 1 + 7 + 1 + 1 = 10 queries. Previous approach: 7 × 4 = 28. Improvement: 64% reduction. Still significant, but "at most 4" is inaccurate.
- **Q4 Path Execution**: N/A (spec review, no code to execute).
- **Suggested Fix**: Change §3 to: "reduces from N*4 to U+3 queries, where U = number of unique groups." Add worst-case and best-case examples.

### [F-02] §5 acceptance criteria not mechanically decidable
- **Level**: 🔴
- **Location**: `spec §5`
- **Description**: "Performance improves significantly" — what is "significantly"? 10%? 50%? Without a number, no one can determine PASS or FAIL after implementation.
- **Q1 Positive Evidence**: §5 text verbatim: "Performance improves significantly."
- **Q2 Falsification**: Implementation reduces queries from 28 to 10 (64%). Is that "significant"? Implementation reduces from 8 to 7 (12.5%). Is that "significant"? Both could argue either way.
- **Q3 Data Validation**: N/A — the criterion itself is unmeasurable.
- **Q4 Path Execution**: N/A.
- **Suggested Fix**: Replace with: "For the standard test scenario (7 items, 7 unique groups), query count drops from 28 to 10 (≥60% reduction). Latency measured via log key `batch_query_complete` duration_ms."

### [F-03] §5 "All existing tests continue to pass" is necessary but not sufficient
- **Level**: 🟡
- **Location**: `spec §5`
- **Description**: Existing tests may not cover the new batch path. Passing old tests only proves no regression on old paths — says nothing about correctness of new batch logic.
- **Q1 Positive Evidence**: §5 only mentions existing tests. No mention of new test cases for batch path.
- **Q2 Falsification**: New batch path has a bug → old tests still pass (they don't exercise batch path) → spec acceptance met but implementation is broken.
- **Q3 Data Validation**: N/A.
- **Q4 Path Execution**: N/A.
- **Suggested Fix**: Add: "New test cases required: (1) batch with 1 item, (2) batch with N items sharing 1 group, (3) batch with N items each in unique group, (4) batch with mixed groups."

## Checklist Summary

### Spec Mode
| Checklist | ✅ | 🔴 | 🟡 | ⬛ |
|-----------|:--:|:--:|:--:|:--:|
| CL-S1 Completeness | 0 | 1 | 1 | 3 |
| CL-S2 Consistency | 0 | 1 | 0 | 3 |
| CL-S3 Implementability | 0 | 1 | 0 | 3 |
| CL-S4 Data Contract | 0 | 0 | 0 | 4 |
| CL-S5 Security/Permissions | 0 | 0 | 0 | 4 |

## Reviewer Honest Disclosure
- **Not verified**: §1-§2 of the spec (not provided for review)
- **Assumptions**: The "7 items, 7 unique groups" scenario is representative of production workload
- **Suggested next step**: Spec author to revise §3 claim and §5 acceptance criteria, then re-review
