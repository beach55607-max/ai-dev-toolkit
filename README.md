# Boundary-First Multi-Repo Engineering

Community-safe Codex skill for multi-repo engineering work.

This skill helps Codex reason about:

- owner repo or runtime
- producer and consumer boundaries
- contract and security surfaces
- rollback risk for durable state
- validation depth that matches risk

It is designed for cases where a task may cross frontend, backend, admin, automation, or browser-extension boundaries.

## Repository Layout

The actual skill lives in:

- `boundary-first-multi-repo-engineering/`

That folder contains:

- `SKILL.md`
- `agents/openai.yaml`
- `references/`

## What The Skill Does

The skill encourages a boundary-first workflow:

1. Classify the change
2. Identify the true owner repo or runtime
3. Check contract surfaces
4. Check security and permission surfaces
5. Check durable state and rollback risk
6. Design observability and debug behavior
7. Choose the right validation depth
8. Pause on stop conditions before coding

## Install

Copy the folder below into your Codex skills directory:

- `boundary-first-multi-repo-engineering/`

Typical destination:

- `~/.codex/skills/boundary-first-multi-repo-engineering/`

Then restart Codex.

## Example Prompts

Explicit invocation:

```text
Use $boundary-first-multi-repo-engineering to do a read-only preflight for a frontend change that may alter a backend request payload. Identify the owner boundary, contract risk, security surface, and required validation.
```

Implicit invocation:

```text
I need to review a change that touches a frontend app, a backend route, and extension storage. Do a read-only boundary analysis first, then tell me which system is the owner and what validation depth is appropriate.
```

## Included Adapters

The skill includes generic adapters for:

- backend service
- frontend app
- admin console
- automation bot or sync worker
- browser extension

## Notes

- This repository intentionally avoids company-specific repo names, internal architecture, or private validation commands.
- The public skill keeps the method, not the internal topology.
