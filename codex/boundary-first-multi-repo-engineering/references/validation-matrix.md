# Validation Matrix

Use this reference after the owner path is clear.

## Validation Order

1. Run the narrowest relevant test first.
2. Run repo-standard lint and test commands.
3. Run the stronger build, package, gate, or integration path when the repo defines one.

When executable-spec-planning is in play, record the chosen validation path inside the spec's phase gates and close-out.

Do not stop at unit tests alone when the affected system owns auth, persistence, schema, permissions, or shared contracts.

## Validation By Adapter

### Backend Service

- route or handler-focused tests
- validation or schema tests
- storage or repository tests
- repo-standard lint and test
- build or strong gate when auth, persistence, or shared contracts change

### Frontend App

- mapper or state-focused tests
- component or page tests where present
- repo-standard lint and test
- build verification
- end-to-end or consumer-producer validation when backend-facing payloads change

### Admin Console

- focused tests for review, schema, sync, or promotion flows
- repo-standard lint and test
- build or CI bundle when operator-visible workflows change

### Automation Bot Or Sync Worker

- focused unit tests for parsers, transforms, or orchestration logic
- dry-run or fixture-based validation when available
- repo-standard lint and test
- integration checks for external API, spreadsheet, or chat workflows when safe

### Browser Extension

- focused tests for message routing, storage, or background logic
- repo-standard lint and test
- build or packaging verification
- runtime smoke checks when manifest, permissions, or host access change

## Mapping Into Executable Spec

- D0 local work may use `guards/gate-quick-d0.md` plus the narrowest relevant tests.
- D1+ work should pair repo validation with the executable spec rubric and checker review.
- Cross-repo contract changes should show both producer and consumer validation paths in the downstream spec.

## When Validation Is Blocked

State exactly which command was skipped and why:

- missing dependency
- no safe local environment
- needs remote secret or deployment credential
- unrelated existing repo failure

Do not claim a gate passed if only a narrower command was run.
