# Example: Code Review — Cache Update Function

## Review Request

```
Mode: Code
Intensity: L2 Standard
Target: updateUserPreferences() function
```

### Code Under Review

```javascript
async function updateUserPreferences(userId, preferences) {
  // Update database
  await db.prepare('UPDATE user_prefs SET data = ? WHERE user_id = ?')
    .bind(JSON.stringify(preferences), userId)
    .run();

  // Update cache
  await cache.put(`prefs:${userId}`, JSON.stringify(preferences), {
    expirationTtl: 86400
  });

  console.log('preferences updated', { userId });
  return { success: true };
}
```

---

## Example Review Output

# Adversarial Code Review Report

## Meta
- **Reviewer**: Claude.ai
- **Target**: `updateUserPreferences()` in `src/handlers/user.js:L42-L55`
- **Date**: 2026-03-29
- **Mode**: Code
- **Intensity**: L2 Standard
- **Overall**: 🟡 CONDITIONAL-GO

## Findings

### [F-01] Cache inconsistency on DB failure rollback
- **Level**: 🔴
- **Location**: `user.js:L48-L52`
- **Description**: If `db.prepare().run()` succeeds but a later operation fails and triggers a rollback, the cache already has the new value. No cache invalidation on rollback path.
- **Q1 Positive Evidence**: DB write at L45, cache write at L48. Both execute sequentially.
- **Q2 Falsification Scenario**: (1) DB write succeeds, (2) downstream operation fails, (3) DB rolls back, (4) cache still has new preferences → user sees rolled-back data on next DB read but cached data on cache hit. Inconsistency window = up to 86400 seconds.
- **Q3 Data Validation**: If TTL = 86400 (24h), any rollback within that window serves stale cached data.
- **Q4 Path Execution**: No rollback handler visible. No cache.delete() on error path.
- **Same Pattern**: Check if other cache-write functions have the same pattern (`grep 'cache.put' src/`).
- **Suggested Fix**: Wrap in try-catch; on failure, delete cache key before re-throwing.

### [F-02] `console.log` but no structured error handling
- **Level**: 🟡
- **Location**: `user.js:L53`
- **Description**: Only logs success. No error logging. No try-catch. If `db.prepare().run()` throws, caller gets unhandled promise rejection.
- **Q1 Positive Evidence**: No try-catch wrapping the function body.
- **Q2 Falsification**: User sends malformed preferences → `JSON.stringify` succeeds (valid JS object) but DB rejects (too large) → unhandled error.
- **Q3 Data Validation**: N/A for this finding.
- **Q4 Path Execution**: Error path does not exist in code. Cannot be exercised.
- **Same Pattern**: Check other handler functions for missing try-catch.
- **Suggested Fix**: Add try-catch with structured error logging and cache cleanup.

### [F-03] SQL parameterization is correct
- **Level**: ✅
- **Location**: `user.js:L45`
- **Description**: Uses `.prepare().bind()` pattern correctly. No string concatenation.
- **Q1 Positive Evidence**: `.prepare('UPDATE user_prefs SET data = ? WHERE user_id = ?').bind(...)` at L45.
- **Q2 Falsification**: Attempted to find injection vector — `userId` and `preferences` both go through `.bind()`, not string interpolation. No injection path found.
- **Q3 Data Validation**: Standard parameterized query pattern.
- **Q4 Path Execution**: Standard pattern, exercised by any call to this function.

## Checklist Summary

### Code Mode
| Checklist | ✅ | 🔴 | 🟡 | ⬛ |
|-----------|:--:|:--:|:--:|:--:|
| CL-1 Database | 1 | 0 | 0 | 6 |
| CL-2 Cache/Storage | 0 | 1 | 0 | 4 |
| CL-3 Data Semantics | 0 | 0 | 0 | 7 |
| CL-4 Fallback/Error | 0 | 0 | 1 | 5 |
| CL-5 Temporal/Cross-Phase | 0 | 0 | 0 | 5 |

## Execution Evidence

| # | Command | Output Summary | Conclusion |
|---|---------|---------------|------------|
| 1 | `grep -rn 'cache.put' src/` | Found 4 occurrences across 3 files | F-01 pattern exists in 2 other functions (same risk) |

## Reviewer Honest Disclosure
- **Not verified**: Whether the DB layer has automatic rollback on downstream failures (depends on transaction scope not visible in this snippet)
- **Assumptions**: Cache TTL of 86400 is the actual production value; no cache-aside pattern elsewhere
- **Suggested next step**: Check if this function is called within a transaction wrapper; if yes, F-01 severity increases
