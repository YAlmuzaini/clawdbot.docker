# OpenClaw Deployment Guide

Quick reference for deploying OpenClaw locally or with Coolify.

## 🚀 Coolify Deployment (Recommended)

### Files Used
- `templates/compose/openclaw.yaml` - Coolify service template

### Environment Variables
| Variable | Source | Notes |
|----------|--------|-------|
| `SERVICE_PASSWORD_OPENCLAW` | **Auto-generated** by Coolify | Your gateway token |
| `OPENCLAW_GATEWAY_TOKEN` | Auto-set (same as above) | Used by OpenClaw |
| `OPENCLAW_GATEWAY_BIND` | Static: `lan` | Network bind address |
| `OPENCLAW_GATEWAY_PORT` | Static: `18789` | Gateway port |

### Storage
Coolify automatically creates and manages:
```
/data/coolify/applications/<app-id>/openclaw-config → /home/node/.openclaw
/data/coolify/applications/<app-id>/openclaw-workspace → /home/node/.openclaw/workspace
```

### Steps
1. In Coolify: **Services** → **One-Click Services** → Search **"OpenClaw"**
2. Click **Deploy**
3. Wait for deployment to complete
4. Go to **Environment Variables** → Find `SERVICE_PASSWORD_OPENCLAW`
5. Copy the token value
6. Open your assigned domain (e.g., `https://openclaw-xxx.yourdomain.com`)
7. Paste the token → Done! ✅

---

## 💻 Local Development

### Files Used
- `docker-compose.yml` - Local development compose file
- `.env` - Your local environment variables (you create this)

### Environment Variables
| Variable | Source | Notes |
|----------|--------|-------|
| `OPENCLAW_GATEWAY_TOKEN` | **Manual** - Set in `.env` | Generate with `openssl rand -hex 32` |
| `OPENCLAW_GATEWAY_BIND` | `.env` (default: `lan`) | Network bind address |
| `OPENCLAW_GATEWAY_PORT` | `.env` (default: `18789`) | Gateway port |
| `OPENCLAW_CONFIG_DIR` | `.env` (default: `./openclaw-config`) | Local config path |
| `OPENCLAW_WORKSPACE_DIR` | `.env` (default: `./openclaw-workspace`) | Local workspace path |

### Storage
Local directories created in project root:
```
./openclaw-config → /home/node/.openclaw
./openclaw-workspace → /home/node/.openclaw/workspace
```

### Steps
```bash
# 1. Clone repository
git clone https://github.com/yourusername/openclaw.docker.git
cd openclaw.docker

# 2. Create .env file
cp .env.example .env

# 3. Generate secure token
openssl rand -hex 32

# 4. Edit .env and paste token
nano .env  # or your favorite editor
# Set: OPENCLAW_GATEWAY_TOKEN=<your_generated_token>

# 5. Start gateway
docker compose up -d openclaw-gateway

# 6. Access Control UI
open http://localhost:18789

# 7. Paste your token from .env
```

---

## 📊 Quick Comparison

| Feature | Coolify | Local |
|---------|---------|-------|
| **Setup Time** | 2 minutes | 5 minutes |
| **Token Generation** | Automatic | Manual |
| **SSL/HTTPS** | Automatic | Manual (not included) |
| **Domain** | Automatic | localhost |
| **Persistence** | Managed by Coolify | Local directories |
| **Updates** | Redeploy in UI | `docker compose pull && up -d` |
| **Best For** | Production, VPS | Development, Testing |

---

## 🔧 Common Commands

### Coolify
```bash
# View logs (in Coolify UI)
Services → Your OpenClaw → Logs

# Restart service
Services → Your OpenClaw → Restart

# View environment variables
Services → Your OpenClaw → Environment Variables
```

### Local
```bash
# View logs
docker compose logs -f openclaw-gateway

# Restart gateway
docker compose restart openclaw-gateway

# Stop gateway
docker compose down

# Update to latest image
docker compose pull
docker compose up -d openclaw-gateway

# Run CLI commands
docker compose run --rm openclaw-cli channels login
docker compose run --rm openclaw-cli channels add --channel telegram --token <TOKEN>
```

---

## 🔐 Security Notes

### Token Security
- **Never commit** your `.env` file with tokens to git
- **Never share** your gateway token publicly
- **Rotate tokens** periodically for production use
- **Use HTTPS** in production (Coolify handles this automatically)

### Coolify Production
- ✅ Automatic HTTPS via Let's Encrypt
- ✅ Automatic token generation
- ✅ Managed persistence
- ✅ Automatic proxy routing
- ✅ Easy rollbacks

### Local Development
- ⚠️ HTTP only (no SSL by default)
- ⚠️ Manual token management
- ⚠️ Manual backups needed
- ✅ Full control over configuration
- ✅ Fast iteration for development

---

## 📚 Next Steps

### After Deployment
1. **Configure Model Providers** - Add OpenAI, Anthropic, or Google API keys
2. **Set Up Channels** - Connect WhatsApp, Telegram, or Discord
3. **Create Agents** - Configure your AI agents in the Control UI
4. **Enable Sandboxing** (optional) - For production security

### Resources
- [OpenClaw Documentation](https://docs.openclaw.ai/)
- [Coolify Documentation](https://coolify.io/docs)
- [Docker Documentation](./docs/intsall/docker.md)
- [Hetzner VPS Guide](./docs/platforms/hetzner.md)

---

## ❓ Troubleshooting

### Coolify: Token Not Generated
1. Check **Environment Variables** section
2. Look for `SERVICE_PASSWORD_OPENCLAW`
3. If empty, try redeploying the service
4. Still empty? Manually set `OPENCLAW_GATEWAY_TOKEN` with a secure random token

### Local: Gateway Won't Start
1. Check `.env` file exists: `ls -la .env`
2. Verify token is set: `grep OPENCLAW_GATEWAY_TOKEN .env`
3. Check logs: `docker compose logs openclaw-gateway`
4. Verify port not in use: `lsof -i :18789` (macOS/Linux)

### Both: Can't Access Control UI
1. Verify container is running: `docker ps | grep openclaw`
2. Check logs for errors
3. Verify port is accessible
4. Try accessing via IP instead of localhost (local only)

---

**Need Help?**
- [OpenClaw GitHub Issues](https://github.com/openclaw/openclaw/issues)
- [Coolify Discord](https://coolify.io/discord)
