# Voygent MVP Deployment Guide

## Quick Deploy to Render.com

### Prerequisites
- GitHub repository: `https://github.com/iamneilroberts/librechat`
- Branch: `voygent-mvp`
- Render.com account

### One-Click Deploy

1. **Go to Render Dashboard**: https://dashboard.render.com/

2. **Create New Web Service**:
   - Click "New +" → "Web Service"
   - Connect your GitHub account
   - Select repository: `iamneilroberts/librechat`
   - Branch: `voygent-mvp`
   - Root directory: `apps/librechat`

3. **Configure Service**:
   ```
   Name: voygent-mvp
   Region: Oregon (US West) or closest to your users
   Branch: voygent-mvp
   Runtime: Docker
   Instance Type: Starter ($7/month) or Standard (recommended for production)
   ```

4. **Environment Variables** (click "Advanced" → "Add Environment Variable"):

#### Required Variables:
```bash
# Server
HOST=0.0.0.0
PORT=3080
MONGO_URI=<your-mongodb-connection-string>
DOMAIN_CLIENT=https://voygent-mvp.onrender.com
DOMAIN_SERVER=https://voygent-mvp.onrender.com

# Security (generate secure random strings)
JWT_SECRET=<generate-secure-random-string-64-chars>
JWT_REFRESH_SECRET=<generate-secure-random-string-64-chars>
CREDS_KEY=<generate-32-byte-hex-string>
CREDS_IV=<generate-16-byte-hex-string>

# Voygent Configuration
VITE_FORCE_TRAVEL_AGENT_MODE=true
# VITE_VOYGENT_ADMIN_MODE=true  # Uncomment for admin testing

# API Keys
ANTHROPIC_API_KEY=<your-anthropic-key>
OPENAI_API_KEY=<your-openai-key>
```

5. **Database Setup**:

   **Option A: MongoDB Atlas** (Recommended):
   - Go to https://cloud.mongodb.com/
   - Create free M0 cluster
   - Get connection string
   - Use as `MONGO_URI`

   **Option B: Render PostgreSQL** (if LibreChat supports it):
   - Create Render PostgreSQL database
   - Use connection string in config

6. **Deploy**:
   - Click "Create Web Service"
   - Render will automatically build and deploy
   - Build time: ~5-10 minutes

### Testing Your Deployment

Once deployed, visit: `https://voygent-mvp.onrender.com`

**Expected Behavior with Phase 3**:
- ✅ Model selector should be hidden (forced mode active)
- ✅ Only shows "Claude Sonnet (Premium)" - cannot change
- ✅ Clicking model name does nothing (no dropdown)

**To Test Admin Mode**:
1. Add env var: `VITE_VOYGENT_ADMIN_MODE=true`
2. Redeploy
3. Model selector dropdown should now be clickable
4. Can switch between all configured models

---

## Manual Testing (Local Docker)

If you want to test locally before deploying:

```bash
# Clone the repository
git clone https://github.com/iamneilroberts/librechat.git
cd librechat
git checkout voygent-mvp
cd apps/librechat

# Create .env file
cp .env.example .env
# Edit .env with your API keys and configuration

# Build and run
docker build -t voygent-test .
docker-compose up
```

Visit: http://localhost:3080

---

## Phase 3 Testing Checklist

### ✅ Verification Steps:

1. **Normal User Experience (Forced Mode)**:
   - [ ] Model selector shows current model name
   - [ ] Clicking model name does NOT open dropdown
   - [ ] Cannot switch to different models
   - [ ] New conversations use default endpoint (Claude Sonnet)

2. **Admin Override Testing**:
   - [ ] Set `VITE_VOYGENT_ADMIN_MODE=true`
   - [ ] Redeploy/restart
   - [ ] Model selector now clickable
   - [ ] Can switch between all configured endpoints:
     - Claude Haiku (Cost Effective)
     - Claude Sonnet (Premium)
     - GPT-4 (Fallback)
     - z.ai GLM models

3. **Configuration Verification**:
   - [ ] Check librechat.yaml is loaded correctly
   - [ ] Default endpoint is "Claude Sonnet (Premium)"
   - [ ] System prompt includes Voygent travel agent instructions

---

## Environment Variable Reference

### Voygent-Specific Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `VITE_FORCE_TRAVEL_AGENT_MODE` | No | `false` | Locks users to travel agent endpoint |
| `VITE_VOYGENT_ADMIN_MODE` | No | `false` | Allows admins to override locked mode |

### Security Best Practices

Generate secure secrets:
```bash
# JWT Secret (64 characters)
openssl rand -base64 48

# CREDS_KEY (32 bytes = 64 hex chars)
openssl rand -hex 32

# CREDS_IV (16 bytes = 32 hex chars)
openssl rand -hex 16
```

---

## Troubleshooting

### Issue: Model selector still shows dropdown in forced mode
**Solution**:
- Verify `VITE_FORCE_TRAVEL_AGENT_MODE=true` in environment
- Check browser console for env var value
- Hard refresh browser (Ctrl+Shift+R)

### Issue: Build fails in Docker
**Solution**:
- Check Render build logs
- Verify all environment variables are set
- Ensure MongoDB connection string is correct

### Issue: Cannot switch models even with admin mode
**Solution**:
- Verify `VITE_VOYGENT_ADMIN_MODE=true` is set
- Redeploy to apply environment changes
- Clear browser cache

---

## What's Next

After Phase 3 testing passes:

- **Phase 4**: Core Instructions Integration
- **Phase 5**: Per-Message Cost Display (enable voygent API routes)
- **Phase 6**: Full Docker testing with all features
- **Phase 7**: Production deployment on Render.com

---

## Support

**GitHub Repository**: https://github.com/iamneilroberts/librechat
**Branch**: `voygent-mvp`
**Latest Commit**: `bff0c807` - Phase 3 complete with forced mode

**Documentation**:
- Spec 001: `/home/neil/dev/voygent-mvp/specs/001-fork-librechat/`
- Planning: `/home/neil/dev/voygent-mvp/specs/001-fork-librechat/plan.md`
- Decisions: `/home/neil/dev/voygent-mvp/specs/001-fork-librechat/DECISIONS_SUMMARY.md`
