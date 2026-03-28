# Adapter: Browser Extension

Use this adapter for browser or Chromium extension work, especially manifest, background, storage, and message-passing changes.

## Ownership

This runtime usually owns:

- manifest configuration
- background or service worker logic
- content-script behavior
- extension storage and message routing

## Protected Surfaces

See `constitution.md` for the canonical list. Extension-specific additions:

- `manifest.json` permissions and `host_permissions`
- message passing between extension contexts (background, content script, popup)
- storage schema and migration
- external API auth usage inside the extension runtime

## Validation

- Start with the narrowest storage, routing, or background-focused test.
- Run repo-standard lint and test.
- Run build or packaging verification.
- Add runtime smoke checks when permissions or host access change.

## Stop Conditions

Escalate when the task changes:

- permissions or `host_permissions`
- storage schema
- background message routing
- external API auth or token handling

## Common Mistake Scenario

**It looks like just one more extension permission.**

Situation: a browser extension needs a new `host_permissions` entry, or the background message routing needs one more branch.

A common approach is to update `manifest.json` or the background script, verify the build passes, and ship.

What gets missed:

- Adding a `host_permissions` entry is a permission surface change. Users will see a new permission prompt on update, which may cause them to disable the extension.
- The new host access may affect content scripts that run on matching pages.
- Background message routing changes can break existing message flows between content scripts, popup, and background.
- A successful build does not verify runtime behavior. The extension may build but fail at runtime.

What the preflight catches:

- Step 4 (Security) flags the permission change as a security surface.
- Step 3 (Contract) identifies message routing as a contract between extension contexts.
- Step 7 (Validation) requires runtime smoke checks, not just a build.
- The task gets reframed from "add one permission" to "runtime boundary change affecting user consent, content scripts, and message routing."
