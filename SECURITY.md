# Security Policy

## Overview
This document outlines security practices and policies for the Voygent MVP project.

---

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| MVP     | :white_check_mark: |
| Dev     | :white_check_mark: |

---

## Reporting a Vulnerability

### DO NOT open public issues for security vulnerabilities

Instead, please email security concerns to: **security@voygent.com** (or your designated security contact)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within **48 hours** and provide a timeline for fixes.

---

## Security Best Practices

### API Keys & Secrets

**Never commit secrets to git:**
- Use `.env.local` for local development (gitignored)
- Use Render environment variables for production
- Rotate keys quarterly
- Use different keys for dev/staging/production

**Supported secret types:**
- Anthropic API keys
- Stripe API keys (test and production)
- Database credentials
- Session secrets
- OAuth client secrets

### Environment Variables

**Required secrets** (never commit):
```bash
# LLM Provider
ANTHROPIC_API_KEY=sk-ant-...

# Database
DATABASE_URL=postgresql://user:password@host:port/db

# Stripe
STRIPE_SECRET_KEY=sk_test_... (or sk_live_...)
STRIPE_WEBHOOK_SECRET=whsec_...

# Session
SESSION_SECRET=random-secret-string
JWT_SECRET=another-random-secret
```

**Shared configuration** (safe to commit):
```bash
# See .env.shared.example
APP_NAME=Voygent
FEATURE_*=true/false
PUBLIC_URL=...
```

### Authentication & Authorization

**Session Management:**
- JWT tokens with short TTL (15 minutes)
- Refresh tokens stored in Redis (7 days)
- Secure cookies: `httpOnly`, `secure`, `sameSite=strict`

**Password Requirements:**
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Hashed with bcrypt (cost factor ≥ 12)

**OAuth Integration:**
- Support Google, GitHub OAuth
- Validate redirect URIs
- PKCE flow for public clients

### Rate Limiting

**API Endpoints:**
- **Global:** 100 requests/minute per IP
- **Authentication:** 5 failed attempts/hour per user
- **LLM requests:** Controlled by credit ledger

**Implementation:**
- Redis-backed rate limiter
- Exponential backoff for repeated failures
- CAPTCHA after 3 failed auth attempts

### Stripe Webhook Security

**Verification:**
- Always verify webhook signatures
- Use `stripe.webhooks.constructEvent()`
- Reject unsigned or invalid requests

**Event Handling:**
- Idempotent event processing (check event ID)
- Log all webhook events
- Alert on failed payments or subscription cancellations

**Example:**
```typescript
const signature = req.headers['stripe-signature'];
const event = stripe.webhooks.constructEvent(
  req.body,
  signature,
  process.env.STRIPE_WEBHOOK_SECRET
);
```

### Database Security

**Connection Security:**
- Use SSL/TLS for all database connections
- Connection pooling with max limits
- Prepared statements (prevent SQL injection)

**Data Encryption:**
- Encrypt sensitive columns (PII, payment info)
- Use Postgres `pgcrypto` extension
- Never log passwords or credit card numbers

**Access Control:**
- Principle of least privilege
- Separate read/write roles
- Audit logs for sensitive operations

### Input Validation & Sanitization

**User Input:**
- Validate all input server-side
- Sanitize HTML/SQL/NoSQL injection attempts
- Use parameterized queries

**File Uploads:**
- Validate file types and sizes
- Scan for malware (if applicable)
- Store uploads outside web root

**Example:**
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
});

const validated = userSchema.parse(req.body);
```

### Cross-Site Scripting (XSS)

**Prevention:**
- React auto-escapes by default
- Use `dangerouslySetInnerHTML` sparingly
- Content Security Policy (CSP) headers

**CSP Example:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'
```

### Cross-Site Request Forgery (CSRF)

**Protection:**
- CSRF tokens for state-changing operations
- SameSite cookies
- Verify Origin/Referer headers

### HTTPS & TLS

**Requirements:**
- HTTPS only in production (enforced by Render)
- TLS 1.2+ required
- Redirect HTTP → HTTPS

**Headers:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### Data Privacy (GDPR/CCPA)

**User Rights:**
- Right to access personal data
- Right to delete account and data
- Right to export data

**Implementation:**
- Provide data export API
- Cascade deletes on user account deletion
- Anonymize logs after 90 days

**PII Handling:**
- Minimize collection
- Encrypt at rest
- Redact from logs

### Logging & Monitoring

**Security Logs:**
- Failed authentication attempts
- Unauthorized access attempts
- Stripe webhook failures
- Database connection errors

**Alerting:**
- Spike in failed logins
- Unusual API usage patterns
- High error rates
- Slow query alerts

**Log Retention:**
- Security logs: 1 year
- Application logs: 90 days
- Anonymize/redact PII before storage

### Dependency Management

**Updates:**
- Weekly dependency scans (Dependabot)
- Monthly security updates
- Critical patches within 48 hours

**Audit:**
```bash
npm audit
npm audit fix
```

**Tools:**
- GitHub Dependabot
- Snyk (optional)
- OWASP Dependency-Check

### Secure Development Lifecycle

**Code Review:**
- All PRs require review
- Security-focused review for auth/payment code
- Automated SAST scans (optional)

**Testing:**
- Security test cases in test suite
- Penetration testing before major releases
- Bug bounty program (future)

---

## Incident Response

### Response Plan

1. **Detection:** Monitoring alerts or user report
2. **Assessment:** Severity and impact analysis
3. **Containment:** Isolate affected systems
4. **Remediation:** Deploy fix
5. **Communication:** Notify affected users
6. **Post-Mortem:** Document lessons learned

### Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| Critical | Data breach, system compromise | < 1 hour |
| High | Auth bypass, payment failure | < 4 hours |
| Medium | Limited exposure, feature broken | < 24 hours |
| Low | Minor bug, no security impact | Next release |

---

## Compliance

### Standards
- OWASP Top 10
- PCI DSS (for payment processing via Stripe)
- GDPR (if serving EU users)
- SOC 2 (future consideration)

### Audits
- Annual security review
- Quarterly dependency audits
- Continuous monitoring

---

## Security Contacts

- **General Security:** security@voygent.com
- **Stripe Security:** https://stripe.com/docs/security
- **Render Security:** https://render.com/docs/security

---

## Acknowledgments

We thank security researchers who responsibly disclose vulnerabilities. Recognition will be provided in release notes (with permission).

---

## Updates

This security policy is reviewed quarterly and updated as needed. Last updated: [Initial version]
