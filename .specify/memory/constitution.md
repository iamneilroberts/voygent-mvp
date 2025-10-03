# Voygent MVP Constitution

## Core Principles

### I. Critical Path Focus
Every change must answer: **"Is this effort on the critical path to getting a functional MVP on Render.com?"**
- If NO → defer, ticket it, or put behind a feature flag
- If YES → proceed with the smallest change that preserves local→Docker→Render parity
- PR template enforces this question on every pull request

### II. Local→Docker→Render Parity (NON-NEGOTIABLE)
All changes must work identically across all three environments:
- Same Dockerfile for local development and Render deployment
- No Render-specific hacks or workarounds
- Environment variables manage environment differences
- If it isn't reproducible locally in Docker, it doesn't exist

### III. Minimal LibreChat Modifications
Maintain fork compatibility and minimize technical debt:
- Feature flags control all custom behavior
- UI changes scoped to new components (avoid editing core LibreChat files)
- Document all deviations from upstream
- Regular upstream sync strategy required

### IV. Spec-Driven Development
All features start with a specification:
- Spec written → User approved → Tests written → Implementation
- Specs live in `/specs` directory
- Use Spec-Kit templates for consistency
- Reconcile specs from multiple sources regularly

### V. Quality Gates
Code quality is non-negotiable:
- Smoke tests must pass before merge
- CI pipeline validates lint, build, Docker
- Tasks < 90 minutes; if blocked 30 min, write blocker note and switch tasks
- Test coverage maintained or improved

## Definition of Done (MVP)

A feature is complete when it meets ALL criteria:
- ✅ Deploys from GitHub to Render using the same Dockerfile as local
- ✅ Works in local Docker environment
- ✅ Smoke tests pass
- ✅ Documented in specs
- ✅ Behind feature flag if not core MVP functionality
- ✅ Session logging and telemetry integrated (if applicable)

## Development Workflow

### Branch Strategy
- `main` - Production-ready code
- `dev` - Integration branch for features
- `feature/*` - Individual feature branches
- `fix/*` - Bug fixes

### PR Process
1. Branch from `dev`
2. Answer critical path question in PR description
3. Ensure CI passes (lint, build, smoke tests)
4. Get review approval
5. Merge to `dev`
6. Promote `dev` → `main` for production

### Time Management
- Tasks should be < 90 minutes
- If blocked for 30 minutes, document blocker and switch tasks
- Avoid speculative refactoring without failing tests or explicit MVP need

## Technical Constraints

### Technology Stack
- Node.js 20.x (specified in `.nvmrc`)
- PostgreSQL 15+ with pgvector extension
- Redis 7+ for caching and sessions
- Anthropic Claude (primary LLM)
- Stripe for payments
- Render.com for hosting

### Performance Budgets
- Initial page load: < 2s (p95)
- Chat response: < 3s (p95)
- Search results: < 500ms (p95)
- Database queries: < 100ms (p95)

### Security Requirements
- No secrets in git (use environment variables)
- API keys rotated quarterly
- Rate limiting on all public endpoints
- Input validation and sanitization required
- HTTPS-only in production

## Governance

This constitution supersedes all other practices and guidelines.

### Amendment Process
- Amendments require documentation of rationale
- Team discussion and approval required
- Migration plan for existing code if needed
- Version bump and changelog entry

### Compliance
- All PRs reviewed for constitutional compliance
- Critical path question must be answered
- Deviations require explicit justification and approval
- Use `/CLAUDE.md` for AI assistant development guidance

**Version**: 1.0.0 | **Ratified**: 2025-10-03 | **Last Amended**: 2025-10-03