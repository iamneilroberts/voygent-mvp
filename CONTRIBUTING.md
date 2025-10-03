# Contributing to Voygent

Thank you for your interest in contributing to Voygent! This guide will help you get started.

---

## Development Environment

### Prerequisites
- **Node.js:** v20.x (specified in `.nvmrc`)
- **Package Manager:** npm (included with Node) or pnpm
- **Docker:** Latest stable version
- **Git:** Latest stable version

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/voygent-mvp.git
   cd voygent-mvp
   ```

2. **Install dependencies:**
   ```bash
   npm install
   # or
   pnpm install
   ```

3. **Set up environment:**
   ```bash
   cp .env.shared.example .env.shared
   cp .env.local.example .env.local
   # Edit .env.local with your local API keys and database URLs
   ```

4. **Start local development:**
   ```bash
   docker compose up
   ```

---

## Development Workflow

### Branching Strategy
- **`main`** - Production-ready code
- **`dev`** - Integration branch for features
- **`feature/*`** - Individual feature branches
- **`fix/*`** - Bug fix branches
- **`chore/*`** - Maintenance tasks

### Creating a Feature Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feature/your-feature-name
```

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, no logic change)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks
- `perf:` Performance improvements

**Examples:**
```
feat(travel-agent): add template menu for trip planning

Implements a modal with predefined trip templates that users can
select to kickstart their travel planning session.

Closes #42
```

```
fix(cost-bar): correct token counting for streaming responses

The token counter was not accumulating tokens properly during
streaming. This fix ensures accurate cost estimation.
```

---

## Code Quality

### Linting
```bash
npm run lint
# or
pnpm lint
```

### Formatting
```bash
npm run format
# or
pnpm format
```

### Type Checking
```bash
npm run type-check
# or
pnpm type-check
```

### Testing
```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

---

## Building & Running

### Local Development
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

### Docker Development
```bash
# Build Docker image
docker build -t voygent-app .

# Run with docker-compose
docker compose up

# Run smoke tests
bash scripts/smoke.sh
```

---

## Pull Request Process

### Before Submitting

1. **Ensure all tests pass:**
   ```bash
   npm test
   npm run lint
   bash scripts/smoke.sh
   ```

2. **Update documentation** if needed

3. **Answer the Critical Path Question:**
   - Is this effort on the critical path to getting a functional MVP on Render.com?
   - If NO: Why is it being included? Should it be behind a feature flag?
   - If YES: Confirm it preserves local→Docker→Render parity

### Submitting a PR

1. **Push your branch:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR** targeting `dev` branch

3. **Fill out the PR template:**
   - Check the "Critical Path" checkbox
   - Provide explanation
   - List testing notes
   - Reference related issues

4. **Wait for CI** to pass

5. **Request review** from maintainers

### PR Review Criteria

- Code follows project style guidelines
- All tests pass
- No decrease in test coverage
- Documentation updated if needed
- Critical Path question answered
- Smoke tests pass
- Docker build succeeds

---

## Development Guidelines

### File Organization
```
src/
├── components/      # React components
├── pages/          # Page components
├── hooks/          # Custom React hooks
├── utils/          # Utility functions
├── api/            # API client code
├── server/         # Backend server code
├── middleware/     # Express middleware
├── models/         # Database models
└── types/          # TypeScript type definitions
```

### Naming Conventions
- **Files:** `kebab-case.ts`
- **Components:** `PascalCase.tsx`
- **Functions/Variables:** `camelCase`
- **Constants:** `UPPER_SNAKE_CASE`
- **Types/Interfaces:** `PascalCase`

### TypeScript Guidelines
- Prefer interfaces over types for object shapes
- Use explicit return types for functions
- Avoid `any` - use `unknown` if type is truly unknown
- Use strict mode (`strict: true` in tsconfig)

### React Guidelines
- Functional components with hooks (no class components)
- Use TypeScript for prop types
- Keep components small and focused
- Extract reusable logic into custom hooks

---

## Testing Guidelines

### Unit Tests
- Test individual functions and components in isolation
- Mock external dependencies
- Aim for >80% coverage on new code

### Integration Tests
- Test API endpoints with real database (test DB)
- Verify feature workflows end-to-end

### Smoke Tests
- Verify basic functionality after build
- Must pass before any PR merge

---

## Working with Feature Flags

When adding experimental features:

1. **Add flag to `.env.shared.example`:**
   ```bash
   FEATURE_YOUR_FEATURE=false
   ```

2. **Check flag in code:**
   ```typescript
   if (process.env.FEATURE_YOUR_FEATURE === 'true') {
     // Feature implementation
   }
   ```

3. **Default to `false` in production**

4. **Document flag in ARCHITECTURE.md**

---

## Database Migrations

1. **Create migration:**
   ```bash
   npm run migrate:create your_migration_name
   ```

2. **Edit migration** in `migrations/`

3. **Test locally:**
   ```bash
   npm run migrate:up
   ```

4. **Include in PR** with rollback instructions

---

## Getting Help

- **Issues:** [GitHub Issues](https://github.com/yourusername/voygent-mvp/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/voygent-mvp/discussions)
- **Documentation:** See `/docs` directory

---

## Code of Conduct

### Our Standards
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Prioritize the project's mission

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or inflammatory comments
- Publishing private information
- Other unprofessional conduct

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

---

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes for significant contributions
- Annual acknowledgment in project documentation
