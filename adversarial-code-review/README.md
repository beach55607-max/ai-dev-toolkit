# Adversarial Code Review Skill

A falsification-first review skill for AI-assisted development. Forces AI reviewers to **prove correctness** instead of rubber-stamping "looks good."

Distilled from 30+ real incidents where AI reviewers (Claude, GPT, Codex) gave wrong answers.

## The Problem

AI code reviewers have systematic failure modes:

- "All tests pass so logic is correct" — but test mocks don't validate SQL semantics
- "Fallback is implemented" — but code only logs a warning, no actual branching
- "Cache write means next read returns new value" — but platform uses eventual consistency
- "Spec says feature X exists" — but code has no such implementation

This skill forces reviewers to provide **evidence, not opinions**.

## What's Inside

```
adversarial-code-review/
├── README.md                          <- You are here
├── SKILL.md                           <- Core skill (paste into any LLM)
├── adversarial-review.md              <- Launcher template (for Claude Code slash commands)
├── references/
│   └── calibration-cases.md           <- 10 real failure cases for reviewer calibration
└── examples/
    ├── example-code-review.md         <- Sample code review request + output
    ├── example-spec-review.md         <- Sample spec review request + output
    └── real-world-catches.md          <- 13 real bugs caught across 11 incidents
```

## Quick Start

### Option 1: Claude Code (as skill)

Copy `adversarial-code-review/` to `.claude/skills/adversarial-code-review/`.
Use `/adversarial-review <target>` or say "review this code."

### Option 2: Codex / ChatGPT / any LLM (paste-based)

1. Start a new conversation
2. Paste the contents of `SKILL.md`
3. Then paste the code / spec / PR you want reviewed
4. Optionally specify: `Mode: Code, Intensity: L2 Standard`

### Option 3: Codex skill directory

Copy to `~/.codex/skills/adversarial-code-review/`, restart Codex.

## Three Review Modes

| Mode | When | What Gets Checked |
|------|------|-------------------|
| **Code Mode** | PRs, code changes, AI-generated code | Database queries, cache keys, data semantics, error handling, temporal dependencies |
| **Spec Mode** | Design docs, specs, architecture proposals | Completeness, internal consistency, implementability, data contracts, security/permissions, code quality constraints |
| **Release Gate Mode** | Pre-deploy verification | Both checklists + deploy verification + cross-validation |

## Three Intensity Levels

| Intensity | When | Cost |
|-----------|------|------|
| **L1 Fast** | Typos, comments, UI copy, low-risk changes | ~2 min, Q1+Q2 only |
| **L2 Standard** | Normal feature work, bug fixes | ~10 min, full checklist + four questions |
| **L3 Adversarial** | Auth, schema, durable writes, cross-service | ~20 min, full workflow + self-falsification |

Map to your severity system: D0/P3 -> L1, D1/P2 -> L2, D2-D3/P0-P1 -> L3.

## Core Method: Four Mandatory Questions

Every finding must answer:

1. **Q1 Positive Evidence** — What specific code line / test proves this works?
2. **Q2 Falsification** — Under what conditions would this break? Did you check?
3. **Q3 Boundary Data** — What real data (not mock) validates correctness?
4. **Q4 Path Execution** — Has the fallback/error path actually been exercised?

Missing any one = UNVERIFIED, not PASS.

## What This Is NOT

- **Not a CI/CD replacement.** This skill reviews; it doesn't build, test, or deploy.
- **Not a deploy governance framework.** Owner, rollback, blast radius decisions are your team's responsibility.
- **Not a schema migration tool.** If you need migration governance, use a dedicated framework.
- **Not automatic approval.** A PASS from this skill means "reviewer verified with evidence," not "safe to ship."

If your team needs deploy governance (owner assignment, rollback SOP, blast radius control), pair this with a boundary-first engineering workflow or your existing deploy process.

## Customization

### Add your own calibration cases

The best cases come from real incidents where an AI reviewer was wrong. See `references/calibration-cases.md` for the template.

### Add domain-specific checklists

Add items to CL-1 through CL-5 (Code) or CL-S1 through CL-S6 (Spec) based on your stack's failure modes.

### Map to your risk classification

If you have D0-D3, P0-P4, or similar severity levels, map them to L1/L2/L3 in the Mode Selection table.

## Related Skills

This skill pairs well with:

- **Boundary-First Engineering** — identifies owner, contract, and validation boundaries before code changes
- **Executable Spec Planning** — produces mechanically verifiable specs before implementation

All available at the parent repository.

## License

MIT. Use freely, adapt to your stack, share your calibration cases with the community.
