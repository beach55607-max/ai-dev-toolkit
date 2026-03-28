# Fallback Adapter

Use this adapter when the task does not match any of the five standard adapters (backend service, frontend app, admin console, automation bot, browser extension).

## When This Applies

- Infrastructure or platform work (CI/CD pipelines, deployment configs, Terraform/Pulumi)
- Shared libraries or monorepo packages consumed by multiple systems
- Database migration or schema-only changes without a clear runtime owner
- Data pipelines, ML model serving, or analytics systems
- Mobile native apps with their own deployment lifecycle
- Any system type not yet covered by a dedicated adapter

## What To Do

Run the standard 8-step preflight from `CLAUDE.md`. Focus especially on:

1. **Owner**: Who owns the contract? Just because code lives in a shared location does not mean ownership is shared.
2. **Consumer**: Who breaks if this changes?
3. **Blast radius**: How many systems are affected? Shared libraries and infrastructure changes often have a wider blast radius than expected.

## Validation

- Use repo-standard lint and test.
- If the repo has a strong gate, prefer it.
- If no tests exist for the affected area, state that explicitly in close-out.
- For infrastructure changes, prefer dry-run or plan commands over direct apply.

## Guidance

If you find yourself reaching for this fallback repeatedly for the same system type, that system deserves its own dedicated adapter file. Create one following the structure of the existing adapters.
