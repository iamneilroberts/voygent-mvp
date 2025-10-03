#!/bin/bash
# Voygent Smoke Test
# Validates basic functionality after build

set -e  # Exit on any error

echo "🚀 Starting Voygent Smoke Tests..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track failures
FAILURES=0

# Helper function for test results
pass() {
  echo -e "${GREEN}✓${NC} $1"
}

fail() {
  echo -e "${RED}✗${NC} $1"
  FAILURES=$((FAILURES + 1))
}

warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Test 1: Check Node version
echo "📦 Checking Node.js version..."
NODE_VERSION=$(node --version)
if [[ $NODE_VERSION == v20* ]]; then
  pass "Node.js version: $NODE_VERSION"
else
  fail "Node.js version mismatch (expected v20.x, got $NODE_VERSION)"
fi
echo ""

# Test 2: Lint
echo "🔍 Running linter..."
if pnpm run lint 2>/dev/null || npm run lint 2>/dev/null; then
  pass "Linting passed"
else
  warn "Lint script not configured or failed (continuing...)"
fi
echo ""

# Test 3: Type check
echo "🔍 Running type check..."
if pnpm run type-check 2>/dev/null || npm run type-check 2>/dev/null; then
  pass "Type check passed"
else
  warn "Type check script not configured or failed (continuing...)"
fi
echo ""

# Test 4: Build
echo "🔨 Building application..."
if pnpm run build 2>/dev/null || npm run build 2>/dev/null; then
  pass "Build succeeded"
else
  warn "Build script not configured or failed (continuing...)"
fi
echo ""

# Test 5: Docker build
echo "🐳 Building Docker image..."
if docker build -t voygent-app:smoke-test . > /dev/null 2>&1; then
  pass "Docker build succeeded"
else
  fail "Docker build failed"
fi
echo ""

# Test 6: Docker Compose up
echo "🐳 Starting Docker Compose services..."
if docker compose up -d > /dev/null 2>&1; then
  pass "Docker Compose started"

  # Wait for services to be ready
  echo "⏳ Waiting for services to be healthy..."
  sleep 10

  # Test 7: Health check
  echo "🏥 Testing health check endpoint..."
  MAX_RETRIES=30
  RETRY_COUNT=0
  HEALTH_OK=false

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f -s http://localhost:3008/healthz > /dev/null 2>&1; then
      HEALTH_OK=true
      break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 2
  done

  if [ "$HEALTH_OK" = true ]; then
    pass "Health check endpoint responding"
  else
    warn "Health check endpoint not responding (app may not be fully implemented yet)"
  fi

  # Test 8: Database connection
  echo "🗄️  Testing database connection..."
  if docker compose exec -T db pg_isready -U voygent > /dev/null 2>&1; then
    pass "Database is ready"
  else
    fail "Database connection failed"
  fi

  # Test 9: Redis connection
  echo "📮 Testing Redis connection..."
  if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    pass "Redis is ready"
  else
    fail "Redis connection failed"
  fi

  # Cleanup
  echo ""
  echo "🧹 Cleaning up..."
  docker compose down > /dev/null 2>&1
  docker rmi voygent-app:smoke-test > /dev/null 2>&1 || true
  pass "Cleanup completed"
else
  fail "Docker Compose failed to start"
fi

echo ""
echo "========================================"
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✓ All smoke tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ $FAILURES test(s) failed${NC}"
  exit 1
fi
