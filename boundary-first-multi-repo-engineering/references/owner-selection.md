# Owner Selection

Use this reference when a short user request does not name the target repo or runtime clearly.

## Primary Signals

- Prefer an explicit path or filename when the user gives one.
- Prefer the repo of the file already open in the IDE when the task names that file.
- Prefer the system that owns validation, persistence, auth, or runtime policy over the caller that only assembles inputs.
- Prefer the repo named in the closest spec when the request is phrased by phase or feature instead of filename.

## Fast Ownership Map

### Backend Service

Typical owner of:

- API routes
- persistence
- validation and policy enforcement
- webhook handling
- queue or worker execution

Common clues:

- `route`
- `handler`
- `service`
- `repository`
- `database`
- `auth`
- `queue`
- `webhook`

### Frontend App

Typical owner of:

- page flows
- client-side composition
- UI state
- frontend environment wiring
- API client usage

Common clues:

- `page`
- `component`
- `store`
- `view`
- `form`
- `Vite`
- `Next.js`
- `React`

### Admin Console

Typical owner of:

- back-office operations
- schema setup or review flows
- moderation or promotion screens
- privileged operator actions

Common clues:

- `admin`
- `review`
- `promote`
- `moderation`
- `backoffice`
- `dashboard`

### Automation Bot Or Sync Worker

Typical owner of:

- scheduled sync
- bot or chat workflows
- ETL or batch jobs
- spreadsheet or document automation

Common clues:

- `cron`
- `sync`
- `bot`
- `worker`
- `sheet`
- `batch`
- `job`

### Browser Extension

Typical owner of:

- manifest permissions
- content scripts
- background logic
- extension storage
- message passing between extension contexts

Common clues:

- `manifest.json`
- `content script`
- `background`
- `service worker`
- `storage`
- `host_permissions`

## When Several Systems Are Involved

Use this order:

1. Identify the system of record.
2. Identify the producer that defines the contract.
3. Identify the consumer that will break if the contract changes.
4. Read the local rules for every touched system before editing.

## First Files To Read

- `AGENTS.md`
- `package.json`
- the nearest spec or design note
- the current owner file for routes, schema, or config
- the closest tests that already exercise the area
