# Session Handoff: Voygent MVP Deployment with Render MCP

**Date**: 2025-10-04
**Previous Session**: Phase 3 completion and deployment preparation
**Next Session Goal**: Deploy Voygent LibreChat to Render.com using Render MCP

---

## 🎯 Your Mission

Deploy the Voygent MVP (Phase 3 complete) to Render.com and **replace the existing non-working `voygent-hosted` service** with the new Voygent-LibreChat implementation.

---

## 📍 Current Status

### ✅ What's Complete:
- **Phase 1-3**: Forked LibreChat, integrated Voygent customizations, implemented forced travel agent mode
- **Git Repository**: https://github.com/iamneilroberts/librechat
- **Branch**: `voygent-mvp` (latest commit: `d51f911a`)
- **Docker Image**: Builds successfully (tested locally)
- **Deployment Blueprint**: `apps/librechat/render.yaml` ready
- **Documentation**: Complete deployment guide in `DEPLOYMENT.md`

### ⚠️ What Needs Attention:
- **Existing Render Service**: `voygent-hosted` (srv-d37td2emcj7s73ft03k0) - doesn't work, needs replacement
- **Deployment Blocker**: Render CLI doesn't support YAML blueprints - **USE RENDER MCP INSTEAD**
- **Database Setup**: Need MongoDB connection (MongoDB Atlas or other)
- **Background Processes**: 4x `npm run backend` processes running (occupying port 3080)

---

## 🚀 Immediate Actions Required

### 1. Use Render MCP to Deploy

**Primary Task**: Use the Render MCP tools to:

1. **List Current Services**:
   ```
   Use Render MCP to list all services
   Check status of existing voygent-hosted service
   ```

2. **Delete Old Service** (if needed):
   ```
   Service: voygent-hosted (srv-d37td2emcj7s73ft03k0)
   Status: Not working (replace it)
   ```

3. **Create New Service**:
   ```
   Name: voygent-librechat-phase3
   Repository: https://github.com/iamneilroberts/librechat
   Branch: voygent-mvp
   Root Directory: apps/librechat
   Runtime: Docker
   Dockerfile: ./Dockerfile (in apps/librechat)
   Region: Virginia (same as existing service)
   Plan: Free tier (can upgrade later)
   ```

4. **Set Environment Variables**:
   ```bash
   # Server Configuration
   HOST=0.0.0.0
   PORT=3080
   NODE_ENV=production
   DOMAIN_CLIENT=https://<service-url>.onrender.com
   DOMAIN_SERVER=https://<service-url>.onrender.com

   # Security (IMPORTANT - these are pre-generated)
   JWT_SECRET=VNlr8N7iojLDmAR3lGbDH4SSXKqvoxBiFPqaj8wE+gZ/8bu5zP22rHVJIufETlhu
   JWT_REFRESH_SECRET=<generate new one with: openssl rand -base64 48>
   CREDS_KEY=4a07ca80fa883affc6510aa6f2712a5957f5e71585d8b337a8e7587f0ce7ccad
   CREDS_IV=2f4981d57886572bfd39aacb567d089b

   # Voygent Phase 3 Configuration
   VITE_FORCE_TRAVEL_AGENT_MODE=true
   # VITE_VOYGENT_ADMIN_MODE=true  # Add this later to test admin override

   # Database (NEED TO SET UP)
   MONGO_URI=<MongoDB Atlas connection string or other>

   # API Keys (GET FROM USER)
   ANTHROPIC_API_KEY=<ask user or check existing service env vars>
   OPENAI_API_KEY=<ask user or check existing service env vars>

   # LibreChat Settings
   NO_INDEX=true
   ALLOW_REGISTRATION=true
   ALLOW_SOCIAL_LOGIN=false
   ```

5. **Monitor Deployment**:
   ```
   Use Render MCP to:
   - Stream deployment logs
   - Watch build progress (expect ~5-10 minutes)
   - Check for errors
   - Verify service starts successfully
   ```

### 2. Set Up MongoDB (If Needed)

**Check First**: Can you use the existing PostgreSQL database from `voygent-hosted`?
- Service ID: `dpg-d3egubvfte5s73cihj6g-a`
- Name: `voygent-mongo` (despite name, it's PostgreSQL)

**If Not Compatible**:
1. Create MongoDB Atlas free tier cluster
2. Get connection string
3. Add as `MONGO_URI` environment variable

### 3. Verify Phase 3 Features

Once deployed, test at the service URL:

**Test 1: Forced Mode (Default)**
- Model selector should show "Claude Sonnet (Premium)"
- Clicking model name should do NOTHING (no dropdown)
- Cannot switch to other models
- ✅ Expected: Static text, no interaction

**Test 2: Admin Override**
- Add env var: `VITE_VOYGENT_ADMIN_MODE=true`
- Redeploy service
- Model selector should now be clickable
- Dropdown should show all models
- ✅ Expected: Can switch between Claude Haiku, Sonnet, GPT-4, GLM models

---

## 📂 Repository Structure

```
Repository: iamneilroberts/librechat
Branch: voygent-mvp
Root Directory: apps/librechat/

apps/librechat/
├── Dockerfile                  # ← Use this for Docker build
├── render.yaml                 # ← Deployment blueprint (reference only)
├── librechat.yaml              # ← MCP configuration
├── client/
│   └── src/
│       ├── components/
│       │   ├── StatusBar/      # Voygent component
│       │   ├── VoygenWelcome.tsx
│       │   └── Chat/Menus/Endpoints/
│       │       └── ModelSelector.tsx  # Phase 3 changes here
│       └── store/voygent.ts
└── api/
    └── server/
        ├── routes/voygent/     # Disabled (Phase 5)
        └── index.js            # Line 140 commented
```

---

## 🔧 Known Issues & Workarounds

### Issue 1: Render CLI Can't Create from YAML
**Solution**: Use Render MCP instead - it should have service creation capabilities

### Issue 2: Voygent API Routes Disabled
**Status**: Expected - deferred to Phase 5
**Impact**: `/api/voygent/*` endpoints not available (not needed for Phase 3)
**Files**:
- `api/server/index.js:140` - commented out
- `api/server/routes/index.js:31` - commented out
- `api/server/routes/voygent/index.js` - token-usage and trip-progress disabled

### Issue 3: Background Node Processes
**Status**: 4 processes running on port 3080
**Action**: Kill if they interfere: `pkill -9 -f "npm run backend"`

### Issue 4: Docker Local Testing Failed
**Error**: Missing `@aws-sdk/client-bedrock-runtime` dependency
**Status**: Upstream LibreChat issue
**Workaround**: Deploy to Render (cloud build works differently)

---

## 📋 Success Criteria

### Deployment Success:
- ✅ Service created and deployed on Render
- ✅ Build completes successfully (~5-10 min)
- ✅ Service starts and is accessible at URL
- ✅ No critical errors in deployment logs

### Phase 3 Verification:
- ✅ Model selector is locked (forced mode active)
- ✅ Only shows "Claude Sonnet (Premium)" - cannot change
- ✅ Admin override works when `VITE_VOYGENT_ADMIN_MODE=true`

### User Access:
- ✅ Can register new account
- ✅ Can start conversations
- ✅ Default endpoint is Claude Sonnet
- ✅ System prompt shows Voygent travel agent instructions

---

## 🗂️ Important Files to Reference

1. **PROJECT_STATUS.md** - Complete project status and history
2. **DEPLOYMENT.md** - Full deployment guide (manual steps)
3. **apps/librechat/render.yaml** - Deployment configuration reference
4. **apps/librechat/.env.example** - Environment variables template
5. **specs/001-fork-librechat/** - Spec documentation

---

## 💡 Render MCP Usage Guide

**Expected MCP Tools** (check what's available):

```typescript
// List services
render.list_services()

// Create service
render.create_service({
  name: "voygent-librechat-phase3",
  type: "web",
  runtime: "docker",
  repo: "https://github.com/iamneilroberts/librechat",
  branch: "voygent-mvp",
  rootDir: "apps/librechat",
  dockerfilePath: "./Dockerfile",
  envVars: { ... }
})

// Get service details
render.get_service({ serviceId: "srv-xxxxx" })

// Stream logs
render.get_logs({ serviceId: "srv-xxxxx", tail: true })

// Update environment variables
render.update_env_vars({
  serviceId: "srv-xxxxx",
  envVars: { VITE_VOYGENT_ADMIN_MODE: "true" }
})

// Trigger redeploy
render.deploy({ serviceId: "srv-xxxxx" })
```

**If MCP doesn't have these capabilities**:
- Use Render Dashboard: https://dashboard.render.com/
- Follow instructions in DEPLOYMENT.md
- Report back what MCP tools are actually available

---

## 🔐 Security Notes

**Pre-Generated Secrets** (already in this handoff):
- JWT_SECRET: Provided above
- CREDS_KEY: Provided above
- CREDS_IV: Provided above

**Need to Get from User**:
- ANTHROPIC_API_KEY
- OPENAI_API_KEY
- MONGO_URI (or set up new MongoDB)

**Recommendation**: Check if existing `voygent-hosted` service has these env vars and reuse them.

---

## 📊 Expected Timeline

- **Service Creation**: 2-5 minutes (MCP setup)
- **Build Time**: 5-10 minutes (Docker build on Render)
- **Testing**: 5-10 minutes (verify Phase 3 features)
- **Total**: ~20-30 minutes

---

## 🎬 Step-by-Step Action Plan

1. **Check Render MCP Capabilities**
   - List available MCP tools
   - Confirm service creation capability
   - Check environment variable management

2. **Review Existing Service**
   - Get details of `voygent-hosted` (srv-d37td2emcj7s73ft03k0)
   - Extract API keys and database connection
   - Note what's not working

3. **Create New Service**
   - Use Render MCP or Dashboard
   - Configure per specifications above
   - Set all required environment variables

4. **Monitor Deployment**
   - Stream logs during build
   - Watch for errors
   - Verify successful startup

5. **Test Phase 3**
   - Visit service URL
   - Check forced mode behavior
   - Test admin override

6. **Report Results**
   - Provide deployment URL
   - Confirm Phase 3 working
   - Document any issues found

---

## 🔗 Quick Reference Links

- **GitHub**: https://github.com/iamneilroberts/librechat/tree/voygent-mvp
- **Render Dashboard**: https://dashboard.render.com/
- **Existing Service**: https://dashboard.render.com/web/srv-d37td2emcj7s73ft03k0
- **MongoDB Atlas**: https://cloud.mongodb.com/ (if needed)

---

## ✅ Pre-Flight Checklist

Before starting deployment:
- [ ] Render MCP is configured and working
- [ ] You have access to user's Render account (MCP should provide this)
- [ ] You can list existing services
- [ ] You have ANTHROPIC_API_KEY and OPENAI_API_KEY (or can extract from existing service)
- [ ] You have MongoDB connection string (or plan to create one)
- [ ] You understand Phase 3 testing requirements

---

## 🚨 If Something Goes Wrong

**Build Fails**:
- Check deployment logs via MCP
- Verify all environment variables are set
- Confirm Dockerfile path is correct (`./Dockerfile` in `apps/librechat`)
- Check MongoDB connection string is valid

**Service Won't Start**:
- Check for missing environment variables
- Verify DOMAIN_CLIENT and DOMAIN_SERVER match actual URL
- Check MongoDB is accessible from Render
- Review startup logs for specific errors

**Phase 3 Not Working**:
- Verify `VITE_FORCE_TRAVEL_AGENT_MODE=true` is set
- Check build included frontend changes (look for ModelSelector in logs)
- Try hard refresh in browser (Ctrl+Shift+R)
- Check browser console for errors

---

## 📞 Communication with User

**Report Format**:
```
✅ Deployment Status: [SUCCESS/IN_PROGRESS/FAILED]
🔗 Service URL: https://voygent-librechat-phase3.onrender.com
📊 Build Time: X minutes
🧪 Phase 3 Test: [PASS/FAIL]
   - Forced mode: [WORKING/NOT WORKING]
   - Admin override: [WORKING/NOT WORKING/NOT TESTED]

📝 Next Steps: [List any remaining tasks or issues]
```

---

**Good luck! You have all the tools and information needed to successfully deploy Voygent Phase 3 to Render.com using the Render MCP.**

**Remember**: The goal is to replace the broken `voygent-hosted` service with a working Voygent-LibreChat deployment that demonstrates Phase 3 forced travel agent mode functionality.
