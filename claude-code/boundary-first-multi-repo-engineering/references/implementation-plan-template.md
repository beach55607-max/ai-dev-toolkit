# Implementation Plan Template

Use this template when the Decision Gate classifies the task as D1, D2, or D3. D0 tasks should use `templates/d0-spec-template.md` (from executable-spec-planning skill) instead of this template.

## When To Use

- **D1**: fill Assumption, Owner, Rollback stance. Other fields optional.
- **D2**: fill all fields. Producer/consumer impact and validation plan are required.
- **D3**: fill all fields. User confirmation required before proceeding to implementation.

## Template

```markdown
## Implementation Plan

Severity: D1 / D2 / D3
Assumption: [what behavior is expected to change and why]
Owner: [repo and layer that owns the change]
Consumer: [repo or caller affected]

### Contract Surface
- [list request/response shapes, auth headers, canonical strings, schema fields, env bindings, storage keys, or message formats that change]
- [or "none" if no contract surface is affected]

### Security Surface
- [list HMAC, auth, nonce/timestamp, secrets, D1/KV/Sheet writes, extension permissions, or host access affected]
- [or "none" if no security surface is affected]

### Validation Plan
- [specific commands on owner side: e.g., npm run gate:pr for lg-proxy-worker]
- [specific commands on consumer side, if D2/D3: e.g., npm run ci for lg-s5-admin-hub]
- [strongest gate to run, if available]

### Rollback Stance
- [how to revert if the change fails]
- [or "no durable state change" if not applicable]
- [for D2/D3: staged rollout plan if breaking change, dual-format transition window]

### Unknowns
- [anything that could not be verified before implementation]
- [or "none"]
```

## SSOT Hierarchy

- **Implementation Plan** = preflight input. Documents assumption, owner, rollback stance before coding.
- **Implementation Spec** = execution SSOT. Documents scope, locked decisions, phases, gates, contracts.
- **If conflict exists after spec approval, the Spec supersedes the Plan.**
- Close-out references both: Plan for "planned vs actual", Spec for verification evidence.

## Rules

- Do not start implementation until the plan is stated. For D3, do not start until the user confirms.
- The plan does not need to be long. A D1 plan can be 3 lines. The goal is to make the assumption, owner, and rollback stance explicit before coding.
- If the plan changes during implementation (new surfaces discovered, scope expanded), update the plan before continuing.
- Reference this plan in the close-out template to show what was planned vs what actually happened.