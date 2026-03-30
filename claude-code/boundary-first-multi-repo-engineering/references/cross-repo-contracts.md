# Cross-Repo Contracts

Use this reference when one change can ripple into another repo.

## Contract-First Rule

Before editing, determine:

- Who owns the contract
- Which repo consumes it
- Which artifact is the source of truth

Do not treat payloads, schema fields, route names, or env bindings as local-only details.

## LG Contract Surfaces

### LIFF Frontend <-> Proxy Worker

- Request body shape
- Response field names
- Auth headers and LIFF token usage
- Route paths under worker handlers
- Shared constants or enum-like option values

Typical owner:
- Backend routes and persistence in `lg-proxy-worker`
- UI flow and request composition in `lg-liff`

### S5 Admin Hub <-> Proxy Worker Admin API

- Sheet tab name to admin route mapping
- HMAC canonical format, body hash, and headers
- Sync payload modes: `full` and `diff`
- Pull response shape and field cleanup rules
- D1 table naming, config version recording, snapshot or rollback expectations

Typical owner:
- Sheet schema and menu flows in `lg-s5-admin-hub`
- Admin route implementation and D1/KV persistence in `lg-proxy-worker`

### LINE Bot GAS <-> Proxy Worker

- HMAC or admin auth conventions
- Store-list and whitelist payload shapes
- Role, permission, and sync schema alignment
- Shared enum normalization across GAS, D1, and worker adapters

Typical owner:
- User-facing GAS workflows in `lg-linebot`
- Backend contract and persistence in `lg-proxy-worker`

### ACL Sync GAS <-> Proxy Worker

- User whitelist sync payload shape and role normalization
- Admin HMAC headers, canonical format, and endpoint contracts under `/api/admin/*`
- Pull-from-D1 response shape, D1 health-check expectations, and delete semantics
- Store-list sync payloads and partial-failure messaging
- Sheet tab names, dynamic role mapping, and PropertiesService-backed config keys

Typical owner:
- Sheet workflow, triggers, and GAS-side orchestration in `lg-acl-sync`
- Backend contract, D1/KV persistence, and admin route behavior in `lg-proxy-worker`

## Safe Change Sequence

1. Read the owner-side SSOT.
2. Read the consumer-side parser or caller.
3. Update tests or fixtures that model the contract.
4. Change owner implementation.
5. Change consumer implementation.
6. Run validation in both repos when possible.

## High-Risk Edits

- D1 column rename or meaning change
- SQL conflict target or delete semantics
- Route rename
- HMAC canonical string, auth header, nonce, or timestamp tolerance changes
- Sheet column order or primary key rules
- Enum case or normalization changes

Treat these as contract migrations, not routine edits.
