# OpenClaw Coolify Service Template

This repository contains the Coolify one-click service template for [OpenClaw](https://github.com/openclaw/openclaw), an AI-powered multi-channel messaging gateway with agent sandboxing capabilities.

## What is OpenClaw?

OpenClaw is a production-grade AI messaging gateway that connects multiple channels (WhatsApp, Telegram, Discord) to LLM providers with advanced features like:

- 🤖 Multi-channel messaging (WhatsApp, Telegram, Discord)
- 🔒 Agent sandboxing with Docker isolation
- 🎯 Multi-agent routing
- 🛠️ Extensible tool system
- 📦 Self-hosted with full data control

## Quick Start with Coolify

### Deploy OpenClaw in Coolify

1. Log into your Coolify instance
2. Navigate to **Services** → **One-Click Services**
3. Search for **OpenClaw**
4. Click **Deploy**
5. Coolify will automatically:
   - Generate a secure gateway token via `SERVICE_PASSWORD_OPENCLAW`
   - Create persistent storage volumes
   - Deploy the OpenClaw gateway
   - Set up proxy routing

6. Once deployed, go to your service's **Environment Variables** section
7. Find `SERVICE_PASSWORD_OPENCLAW` - this is your gateway token (auto-generated)
8. Access the Control UI at your assigned domain
9. Paste the `SERVICE_PASSWORD_OPENCLAW` value into the Control UI

**Note**: Both `SERVICE_PASSWORD_OPENCLAW` and `OPENCLAW_GATEWAY_TOKEN` will have the same value. Use either one.

That's it! OpenClaw is now running and ready to use.

## Local Development/Testing

### Prerequisites

- Docker & Docker Compose v2
- Git

### Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/openclaw.docker.git
cd openclaw.docker
```

2. Copy the environment file:
```bash
cp .env.example .env
```

3. Generate a secure token:
```bash
openssl rand -hex 32
```

4. Edit `.env` and set your `OPENCLAW_GATEWAY_TOKEN`

5. Start the gateway:
```bash
docker compose up -d openclaw-gateway
```

6. Access the Control UI:
```
http://localhost:18789
```

7. Paste your gateway token from `.env`

### Using the CLI

The CLI is useful for configuration tasks like setting up channels:

```bash
# WhatsApp (QR code login)
docker compose run --rm openclaw-cli channels login

# Telegram (bot token)
docker compose run --rm openclaw-cli channels add --channel telegram --token <your_bot_token>

# Discord (bot token)
docker compose run --rm openclaw-cli channels add --channel discord --token <your_bot_token>
```

### Health Check

Verify the gateway is running:

```bash
docker compose exec openclaw-gateway node dist/index.js health --token "$OPENCLAW_GATEWAY_TOKEN"
```

### View Logs

```bash
docker compose logs -f openclaw-gateway
```

## Architecture

### Components

- **Gateway Service**: Main OpenClaw WebSocket/HTTP server
- **CLI Service**: Configuration and management tool
- **Persistent Storage**:
  - `./openclaw-config`: Gateway configuration, tokens, sessions
  - `./openclaw-workspace`: Agent workspace and artifacts

### Ports

| Port | Service | Description |
|------|---------|-------------|
| 18789 | Gateway | Main HTTP/WebSocket interface |

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENCLAW_GATEWAY_TOKEN` | Yes | - | Authentication token for gateway |
| `OPENCLAW_GATEWAY_BIND` | No | `lan` | Network bind address |
| `OPENCLAW_GATEWAY_PORT` | No | `18789` | Gateway port |
| `OPENCLAW_CONFIG_DIR` | No | `./openclaw-config` | Config storage path |
| `OPENCLAW_WORKSPACE_DIR` | No | `./openclaw-workspace` | Workspace storage path |

## Contributing the Template to Coolify

This repository is structured to contribute the OpenClaw service template to the official Coolify repository.

### Files for Coolify Contribution

1. **`templates/compose/openclaw.yaml`** - The main service template
2. **`svgs/openclaw.svg`** - Service logo

### How to Contribute

1. Fork the [Coolify repository](https://github.com/coollabsio/coolify)

2. Copy the template files:
```bash
# Copy template
cp templates/compose/openclaw.yaml <coolify-repo>/templates/compose/

# Copy logo
cp svgs/openclaw.svg <coolify-repo>/svgs/
```

3. Test the template:
   - Use "Docker Compose Empty" in your Coolify instance
   - Paste the template content
   - Deploy and verify all functionality

4. Submit a Pull Request to Coolify:
   - Include both files in your PR
   - Reference this repository in the PR description
   - Add any special configuration notes

### Testing Checklist

Before submitting your PR, verify:

- ✅ Container starts successfully
- ✅ Port 18789 is accessible via Coolify proxy
- ✅ Config directory is created and persists
- ✅ Workspace directory is created and persists
- ✅ Health check passes
- ✅ Gateway token from Coolify magic variable works
- ✅ Control UI loads and accepts token
- ✅ Container restarts retain data

## Troubleshooting

### Coolify Environment Variables

**Q: My `SERVICE_PASSWORD_OPENCLAW` is empty or not generated**

A: After deploying, check your service's Environment Variables section in Coolify. If it's empty:
1. Stop the service
2. In Environment Variables, find `SERVICE_PASSWORD_OPENCLAW`
3. Click the "Generate" or refresh icon next to it
4. Coolify should auto-generate a secure password
5. Save and restart the service

**Q: Where do I find my gateway token?**

A: In Coolify, navigate to your OpenClaw service → **Environment Variables**. Look for either:
- `SERVICE_PASSWORD_OPENCLAW` (auto-generated by Coolify)
- `OPENCLAW_GATEWAY_TOKEN` (same value as above)

Copy this value and paste it into the OpenClaw Control UI.

**Q: My persistent storage paths look different**

A: That's normal! Coolify creates storage paths like:
```
/data/coolify/applications/<app-id>/openclaw-config
```
These automatically map to `/home/node/.openclaw` inside the container. No action needed.

### OpenClaw Issues

**Q: Gateway won't start**

Check the logs:
```bash
# In Coolify, go to Logs section
# Or if using local Docker:
docker compose logs -f openclaw-gateway
```

Common issues:
- Missing or invalid gateway token
- Port conflicts (change `OPENCLAW_GATEWAY_PORT`)
- Volume permission errors

**Q: Can't access Control UI**

1. Verify the gateway is running: Check service status in Coolify
2. Check the domain/URL assigned by Coolify
3. Ensure port 18789 is properly proxied by Coolify

## Documentation

### OpenClaw Documentation
- [Official Docs](https://docs.openclaw.ai/)
- [Docker Setup Guide](./docs/intsall/docker.md)
- [Hetzner VPS Guide](./docs/platforms/hetzner.md)

### Coolify Documentation
- [Docker Compose in Coolify](./docs/coolify-docs/docker/compose.md)
- [Contributing a Service](./docs/coolify-docs/docker/contribute/service.md)
- [Custom Docker Options](./docs/coolify-docs/docker/custom-commands.md)

## Support

- **OpenClaw Issues**: [GitHub Issues](https://github.com/openclaw/openclaw/issues)
- **Coolify Issues**: [GitHub Issues](https://github.com/coollabsio/coolify/issues)
- **OpenClaw Discord**: [Join Community](https://discord.gg/openclaw)

## License

This repository follows the same license as OpenClaw. The Coolify service template is provided as-is for community contribution.

## Credits

- **OpenClaw**: [openclaw/openclaw](https://github.com/openclaw/openclaw)
- **Coolify**: [coollabsio/coolify](https://github.com/coollabsio/coolify)
