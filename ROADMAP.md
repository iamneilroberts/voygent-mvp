# Voygent MVP Roadmap

## Overview
This roadmap outlines the phased approach to shipping a functional Voygent MVP on Render using a forked LibreChat with minimal, controlled modifications.

---

## Phase 1: Parity & Deploy Scaffold
**Goal:** Establish local→Docker→Render parity and basic infrastructure

- [ ] Set up Dockerfile with Node 20 multi-stage build
- [ ] Configure docker-compose.yml with app, postgres, redis services
- [ ] Implement healthcheck endpoint (`/healthz`)
- [ ] Create environment configuration templates
- [ ] Set up CI/CD pipeline for automated testing
- [ ] Deploy basic scaffold to Render
- [ ] Verify local Docker build matches Render deployment

---

## Phase 2: Travel Mode Startup
**Goal:** Auto-start Travel Agent mode with template menu and slash commands

- [ ] Create system prompt for Travel Agent mode
- [ ] Implement template menu interface
- [ ] Build slash command parser and router
- [ ] Add Travel Agent mode auto-start on session creation
- [ ] Seed initial conversation with travel planning context
- [ ] Test template selection workflow
- [ ] Verify mode persistence across sessions

---

## Phase 3: Status Bar & DB Logging
**Goal:** Real-time progress tracking, token counting, and cost estimation

- [ ] Design and implement progress/token-cost status bar UI
- [ ] Create database schema for `llm_sessions` and `llm_messages`
- [ ] Add token counting middleware for all LLM interactions
- [ ] Implement cost estimation based on token usage
- [ ] Build logging hooks for session/message persistence
- [ ] Add real-time status bar updates via WebSocket/SSE
- [ ] Create admin view for session analytics

---

## Phase 4: Trip Search Improvements
**Goal:** Enhanced search using pgvector and full-text search

- [ ] Set up pgvector extension in Postgres
- [ ] Create `trip_index` table with embedding and tsvector columns
- [ ] Implement embedding generation for trip summaries
- [ ] Build hybrid search (semantic + keyword) query engine
- [ ] Import default trip templates and destinations
- [ ] Add search ranking and filtering logic
- [ ] Test search quality with sample queries

---

## Phase 5: Template-Document MCP Tests
**Goal:** Itinerary building and publishing via MCP

- [ ] Design itinerary document schema
- [ ] Implement template → document transformation logic
- [ ] Create MCP server for GitHub publishing
- [ ] Build itinerary export workflow (markdown/PDF)
- [ ] Add collaborative editing support
- [ ] Test publishing to GitHub repositories
- [ ] Verify version control and revision tracking

---

## Phase 6: Stripe Subscriptions & Credit Ledger
**Goal:** Payment processing and usage enforcement

- [ ] Set up Stripe account and test/production keys
- [ ] Design subscription tiers and pricing model
- [ ] Implement credit ledger schema and accounting logic
- [ ] Create Stripe webhook handlers for subscription events
- [ ] Build credit enforcement middleware
- [ ] Add user dashboard for subscription management
- [ ] Implement credit top-up and usage alerts
- [ ] Test payment flows end-to-end
- [ ] Add fraud prevention and rate limiting

---

## Phase 7: Validation Engine
**Goal:** Secondary provider validation with quality badges

- [ ] Select and integrate secondary LLM provider
- [ ] Design validation criteria and scoring rubric
- [ ] Implement itinerary validation workflow
- [ ] Create validation report generator
- [ ] Build badge/quality score display
- [ ] Add validation request queueing
- [ ] Test validation accuracy and performance

---

## Phase 8: Theme Landing Flows
**Goal:** Contextual chat priming based on landing page themes

- [ ] Design theme taxonomy (beach, adventure, cultural, etc.)
- [ ] Create landing page templates for each theme
- [ ] Build theme → context mapping logic
- [ ] Implement chat priming with theme-specific prompts
- [ ] Add A/B testing framework for landing flows
- [ ] Track conversion metrics by theme
- [ ] Optimize chat initialization performance

---

## Success Metrics

### MVP Launch Criteria
- ✅ Deploys successfully to Render from GitHub
- ✅ Local Docker environment matches production
- ✅ All smoke tests pass in CI/CD
- ✅ Healthcheck returns 200 OK
- ✅ Travel Agent mode auto-starts
- ✅ Token cost tracking displays accurately
- ✅ Stripe subscriptions process successfully
- ✅ Itinerary export generates valid documents
- ✅ Validation engine returns quality scores

### Performance Targets
- Page load: < 2s (p95)
- Chat response: < 3s (p95)
- Search results: < 500ms (p95)
- Validation time: < 30s (p95)
- Uptime: > 99.5%

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| LibreChat fork drift | High | Pin to specific commit, minimal modifications, feature flags |
| Render deployment issues | High | Maintain strict local/Docker/Render parity, comprehensive smoke tests |
| Token cost overruns | Medium | Credit enforcement, rate limiting, cost alerts |
| Search quality issues | Medium | Hybrid search, continuous tuning, user feedback loop |
| Stripe integration bugs | High | Extensive webhook testing, idempotency keys, error monitoring |

---

## Notes
- Each phase should be completable within 1-2 weeks
- All work must pass CI and smoke tests before merging to `dev`
- Critical path questions must be answered for every PR
- Feature flags protect incomplete work from production
