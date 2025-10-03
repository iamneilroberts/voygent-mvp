# Voygent MVP

AI-powered travel planning platform built on LibreChat with minimal, controlled modifications.

## Quick Start

```bash
# Clone repository
git clone https://github.com/iamneilroberts/voygent-mvp.git
cd voygent-mvp

# Set up environment
cp .env.shared.example .env.shared
cp .env.local.example .env.local
# Edit .env.local with your API keys

# Start with Docker
docker compose up
```

## Documentation

- [CLAUDE.md](CLAUDE.md) - Project constitution and critical path guidelines
- [ROADMAP.md](ROADMAP.md) - Phased development plan
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture and design
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines
- [SECURITY.md](SECURITY.md) - Security policies
- [docs/specs_status.md](docs/specs_status.md) - Spec status overview

## Project Mission

Ship a functional end-to-end Voygent MVP on Render using a forked LibreChat with minimal, controlled modifications.

## Critical Path Question

Before every PR: **"Is this effort on the critical path to getting a functional MVP on Render.com?"**

- If NO → defer, ticket it, or put behind a feature flag
- If YES → proceed with the smallest change that preserves local→Docker→Render parity

## Definition of Done (MVP)

- ✅ Deploys from GitHub to Render using the same Dockerfile as local
- ✅ Travel Agent mode auto-starts via system+seed messages
- ✅ Progress + token-cost bar visible; session logging stored in DB
- ✅ Stripe subscriptions live; credit ledger enforced server-side
- ✅ Shareable itinerary export works
- ✅ Validation engine callable via secondary provider
- ✅ Cost dashboard shows per-session token/cost/latency

## Development Workflow

1. Branch from `dev` for new features
2. Develop locally with `docker compose up`
3. Test with `bash scripts/smoke.sh`
4. PR to `dev` with critical path checkbox
5. CI runs lint, build, smoke tests
6. Merge to `dev` → promote to `main` for production

## License

MIT
