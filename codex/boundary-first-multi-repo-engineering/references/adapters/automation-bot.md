# Adapter: Automation Bot Or Sync Worker

Use this adapter for scheduled jobs, ETL pipelines, bots, chat workflows, and spreadsheet or document sync automation.

## Ownership

This runtime usually owns:

- orchestration and scheduling
- transforms between external and internal formats
- retry and idempotency behavior
- automation-side diagnostics and job outcomes

## Protected Surfaces

See `constitution.md` for the canonical list. Automation-specific additions:

- external API request and response mapping
- sync payload formats and batch write behavior
- retry semantics and idempotency guarantees
- message or document metadata that affects downstream processing

## Validation

- Start with transform or parser-focused tests.
- Use dry-run or fixture-based validation when available.
- Run repo-standard lint and test.
- Add integration checks when external-system behavior is part of the contract.

## Stop Conditions

Escalate when the task changes:

- idempotency assumptions
- destructive sync behavior
- retry policy with side effects
- external credentials or privileged scopes

## Common Mistake Scenario

**It looks like a small sync transform update.**

Situation: an automation worker needs to change how it maps data before writing to an external system (spreadsheet, third-party API, or shared database).

A common approach is to update the transform function, verify the unit test passes with the new mapping, and ship.

What gets missed:

- The external system may depend on the old data shape. Changing the transform silently changes what gets written.
- Downstream consumers (dashboards, reports, other automations) may parse the output using the old format.
- If the sync is not idempotent, rerunning it after the change may create duplicates or corrupt existing records.
- There may be no way to undo the write to the external system.

What the preflight catches:

- Step 3 (Contract) identifies the external write format as a shared contract surface.
- Step 5 (State) flags the external system write as durable with limited rollback.
- Step 8 (Stop conditions) pauses on destructive sync behavior.
- The task gets reframed from "update a mapper" to "contract migration affecting an external system with no rollback."
