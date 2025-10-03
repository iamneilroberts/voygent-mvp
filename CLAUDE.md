# Voygent Shipping Constitution

## Mission
Ship a functional end-to-end Voygent MVP on Render using a forked LibreChat with minimal, controlled modifications.

## Critical Path Question (ask frequently)
"Is this effort on the critical path to getting a functional MVP on Render.com?"
- If NO → defer, ticket it, or put behind a feature flag.
- If YES → proceed with the smallest change that preserves local→Docker→Render parity.

## Non-Goals
- No direct edits on Render.
- No UI rewrites in cloud before local Docker passes smoke.
- No speculative refactors without a failing test or explicit MVP need.

## Definition of Done (MVP)
- Deploys from GitHub to Render using the same Dockerfile as local.
- Travel Agent mode auto-starts via system+seed messages (template menu + slash commands).
- Progress + token-cost bar visible; session logging stored in DB.
- Stripe subscriptions live; credit ledger enforced server-side.
- Shareable itinerary export works; validation engine callable via secondary provider.
- Cost dashboard shows per-session token/cost/latency.

## Working Agreements
- Branch → PR → CI green → review → merge to `dev` → promote to `main`.
- Tasks < 90 minutes. If blocked 30 minutes, write a blocker note and switch to the next task.
- If it isn't reproducible locally in Docker, it doesn't exist.

---

# Additional Instructions

- Do not use the old database travel_assistant. Use the new database voygent-prod
- Do what has been asked; nothing more, nothing less.
- NEVER create files unless they're absolutely necessary for achieving your goal.
- ALWAYS prefer editing an existing file to creating a new one.
- NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
