# Owner Selection

Use this reference when a short user request does not name the target repo clearly.

## Decision Tree

### Step 1: Explicit Path

Did the user name a specific file or path?

- YES: the owner is the repo containing that file. Go to Step 4.
- NO: go to Step 2.

### Step 2: Responsibility Check

Does the task involve persistence (D1/KV/Sheets), auth (HMAC), validation, or runtime policy?

- YES: the owner is usually `lg-proxy-worker` for backend auth, persistence, and runtime policy. If the task is GAS-side Sheet schema, trigger/menu orchestration, or whitelist sync workflow, the owner stays in the GAS repo (`lg-s5-admin-hub`, `lg-linebot`, or `lg-acl-sync`). Go to Step 4.
- NO: go to Step 3.

### Step 3: Domain Match

- Worker routes, D1/KV, admin API, backend feature logic -> `lg-proxy-worker`
- LIFF apps, shared frontend modules, Vite build -> `lg-liff`
- GAS Sheet admin flows, sync/pull, backup, review/promote -> `lg-s5-admin-hub`
- GAS LINE Bot, whitelist, store-list sync, `doPost` -> `lg-linebot`
- ACL sync behavior -> `lg-acl-sync`
- Chrome extension, ThinQ, Manifest V3 -> `lg-thinq-ext`
- None of the above -> apply preflight directly, state assumed system type, and document why no adapter fit

### Step 4: Identify Consumers

For the identified owner:

1. Which other repos call, depend on, or parse output from this owner?
2. Read `CLAUDE.md` and `AGENTS.md` for every touched repo before editing.

Common cross-repo pairs:

- LIFF request payload change: `lg-liff` + `lg-proxy-worker`
- Admin Hub sync/pull or HMAC change: `lg-s5-admin-hub` + `lg-proxy-worker`
- GAS store-list sync contract: `lg-linebot` + `lg-proxy-worker`
- ACL whitelist sync, health-check, or admin delete flow: `lg-acl-sync` + `lg-proxy-worker`

If two repos have conflicting rules, read `conflict-resolution.md`.

## First Files To Read

- `AGENTS.md`
- `CLAUDE.md` (repo-local)
- `package.json`
- Closest task spec or closure report
- The current owner file for config, schema, or routes
- The nearest tests that already exercise the area
