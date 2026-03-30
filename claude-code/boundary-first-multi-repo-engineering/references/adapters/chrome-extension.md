# Adapter: Chrome Extension / `lg-thinq-ext`

Use this adapter for Chrome or Chromium extension work, especially manifest, background, storage, and message-passing changes in `lg-thinq-ext`.

## Ownership

This adapter owns extension-specific reasoning for:

- `manifest.json`
- Background service worker
- Content scripts
- Popup and options pages
- Message passing
- Extension storage
- Permissions and host permissions
- Packaging and loadability

Default target: Manifest V3 on Chrome/Chromium.

## Boundary Model

Start by deciding which runtime surface owns the behavior:

- `manifest`
- background service worker
- content script
- popup
- options
- shared module

Do not mix surfaces casually. Design message passing contracts explicitly when data moves between surfaces.

## Protected Surfaces

See `constitution.md` for the canonical list. Extension-specific additions:

- `permissions` and `host_permissions`
- Content-script injection scope
- External API/auth headers or tokens
- Storage schema and migration
- Command and message routing

Any expansion of permissions or host permissions is high risk by default.

## Observability

- Keep normal logs for startup, sync, command, API, and message-routing outcomes.
- Put raw payload previews, branch diagnostics, and storage dumps behind `debug_log`.
- Keep debug output off by default via config, env-like build flag, or injected logger behavior.
- Preserve a correlation key when async message chains or background work need tracing.

## Validation

- Standard path: `npm run lint`, `npm run test`, `npm run build`
- Validate at the correct layer: manifest correctness, service worker behavior, popup/options rendering, storage behavior, message passing.
- For greenfield work, acceptance includes build output and extension loadability, not only unit tests.

## Greenfield Preflight

Before designing from scratch, decide:

- whether content scripts are needed
- whether background owns polling or orchestration
- whether popup is read-only or command-capable
- which permissions are strictly necessary
- what storage schema exists and how it evolves
- what normal log vs `debug_log` split is needed

## Stop Conditions

Escalate when the task introduces:

- new `permissions` or `host_permissions`
- new external origins
- new message channels without a defined contract
- durable storage changes without migration or compatibility thought

## Common Mistake Scenario

**It looks like just one more extension permission.**

Situation: `lg-thinq-ext` needs a new `host_permissions` entry, or the background message routing needs one more branch.

A common approach is to update `manifest.json` or the background script, verify `npm run build` passes, and ship.

What gets missed:

- Adding a `host_permissions` entry triggers a new permission prompt on update. Users may disable the extension.
- The new host access may affect content scripts that match on those pages.
- Background message routing changes can break existing flows between content scripts, popup, and background.
- A successful build does not verify runtime behavior.

What the preflight catches:

- Step 4 (Security) flags the permission change as a security surface.
- Step 3 (Contract) identifies message routing as a contract between extension contexts.
- Step 7 (Validation) requires runtime smoke checks, not just a build.
- The task gets reframed from "add one permission" to "runtime boundary change affecting user consent, content scripts, and message routing."