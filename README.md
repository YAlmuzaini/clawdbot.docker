# OpenClaw Docker Deployment for Coolify

> ⚠️ **EXPERIMENTAL - NOT READY FOR PRODUCTION USE** ⚠️
> 
> This Docker image is experimental and was initially created to work with [Coolify](https://coolify.io). It may contain bugs, incomplete features, or other issues. Use at your own risk.

This project contains the Docker configuration for deploying OpenClaw Gateway on [Coolify](https://coolify.io).

## Overview

OpenClaw is a gateway service that can be deployed as a containerized application. This setup includes:

- **Dockerfile**: Builds the OpenClaw image with baked-in binaries
- **docker-compose.yml**: Multi-service configuration for Coolify deployment
- **Persistent storage**: Config and workspace directories survive restarts
- **Health checks**: Automatic health monitoring
- **Optional binaries**: Pre-installed tools (gog, goplaces, wacli)

## Quick Start

### Option A: Using Pre-built Image from Docker Hub (Recommended)

No source code needed! Just use the published Docker image.

   Copy the example environment file and fill in your values:

   ```bash
   cp .env.example .env
   ```

   **Required variables:**
   - `OPENCLAW_GATEWAY_TOKEN`: Generate with `openssl rand -hex 32`
   - `GOG_KEYRING_PASSWORD`: Generate with `openssl rand -hex 32` (if using Gmail)
   - `OPENCLAW_IMAGE`: Set to your Docker Hub image (e.g., `almuzaini/openclaw:latest`)

   Edit `.env` and set all required values.

   - **Create a new Docker Compose resource** in [Coolify](https://coolify.io)
   - **Point to this repository** or upload the `docker-compose.yml` file
   - **Set environment variables** in Coolify's UI (they'll be auto-detected from the compose file)
     - Make sure `OPENCLAW_IMAGE` points to your Docker Hub image
   - **Configure domain** (optional):
     - Assign a domain to the `openclaw-gateway` service
     - Or use `SERVICE_URL_OPENCLAW_GATEWAY` magic variable in your compose file
   - **Deploy**

   The compose file is configured to pull from Docker Hub by default. No source code needed!

### Option B: Building from Source

If you want to build the image yourself or customize it:

1. **Clone the OpenClaw Repository**

   ```bash
   git clone https://github.com/openclaw/openclaw.git
   cd openclaw
   ```

2. **Copy Docker Files**

   Copy the Dockerfile from this repository:

   ```bash
   cp /path/to/openclaw.docker/Dockerfile .
   ```

3. **Build the Image**

   ```bash
   docker build -t yourusername/openclaw:latest .
   ```

4. **Update docker-compose.yml**

   Uncomment the `build:` section and comment out or remove the `image:` line:

   ```yaml
   services:
     openclaw-gateway:
       # image: ${OPENCLAW_IMAGE:-yourusername/openclaw:latest}
       build:
         context: .
         dockerfile: Dockerfile
   ```

5. **Follow steps from Option A** to configure and deploy

For detailed build instructions, see [BUILD.md](./BUILD.md).

## Configuration

### Persistent Storage

The compose file defines two persistent volumes:

- **Config directory** (`./data/.openclaw`): Gateway config, tokens, model auth profiles, skill configs
- **Workspace directory** (`./data/clawd`): Agent workspace, code, and artifacts

These directories are created automatically by [Coolify](https://coolify.io) using `is_directory: true`.

### Service Ports

- **Gateway**: Port `18789` (default)
- **Canvas** (optional): Port `18793` (only if running iOS/Android nodes)

### Environment Variables

All environment variables are automatically detected by Coolify from the compose file. Required variables (marked with `:?`) will be highlighted in the UI.

**Magic Environment Variables** (Coolify-specific):
- `SERVICE_URL_OPENCLAW_GATEWAY`: Auto-generated URL for the gateway
- `SERVICE_FQDN_OPENCLAW_GATEWAY`: Auto-generated FQDN
- `SERVICE_PASSWORD_OPENCLAW_GATEWAY`: Auto-generated password

### Health Checks

The gateway service includes a health check that runs:
```bash
curl -f http://localhost:18789/__openclaw__/canvas/
```

## Using the CLI Service

The `openclaw-cli` service is available for running commands. It uses the `cli` profile, so it won't start automatically.

To use it in Coolify, you can:
1. Run commands via Coolify's terminal/exec feature
2. Or temporarily enable the service

Example commands:

```bash
# Onboarding
docker compose run --rm openclaw-cli onboard

# Channel setup (WhatsApp)
docker compose run --rm openclaw-cli channels login

# Channel setup (Telegram)
docker compose run --rm openclaw-cli channels add --channel telegram --token "<token>"

# Channel setup (Discord)
docker compose run --rm openclaw-cli channels add --channel discord --token "<token>"
```

## Baked-in Binaries

The Dockerfile includes several pre-installed binaries:

- **gog**: Gmail CLI
- **goplaces**: Google Places CLI
- **wacli**: WhatsApp CLI

To add more binaries, edit the `Dockerfile` and add installation commands following the same pattern.

## Accessing the Gateway

### Via Domain (Recommended)

1. Assign a domain to the `openclaw-gateway` service in [Coolify](https://coolify.io)
2. Access via `http://your-domain.com` or `https://your-domain.com`
3. Paste your gateway token in the Control UI (Settings → token)

### Via Direct Port

If you expose the port directly (not recommended for production):
- Access via `http://your-server-ip:18789`
- Ensure proper firewall configuration

## Troubleshooting

### Verify Binaries

Check that binaries are installed correctly:

```bash
docker compose exec openclaw-gateway which gog
docker compose exec openclaw-gateway which goplaces
docker compose exec openclaw-gateway which wacli
```

### Check Logs

```bash
docker compose logs -f openclaw-gateway
```

Look for:
```
[gateway] listening on ws://0.0.0.0:18789
```

### Verify Persistence

After restarting, verify that your config and workspace persist:

```bash
docker compose exec openclaw-gateway ls -la /home/node/.openclaw
docker compose exec openclaw-gateway ls -la /home/node/clawd
```

### Health Check Issues

If health checks are failing:
1. Verify `OPENCLAW_GATEWAY_TOKEN` is set correctly
2. Check that the gateway is actually running
3. Review logs for errors

## Production Considerations

1. **Security**:
   - Use strong, randomly generated tokens
   - Keep `.env` file secure (never commit it)
   - Consider using secrets management in [Coolify](https://coolify.io)

2. **Resource Limits**:
   - Set appropriate memory limits in Coolify (recommend at least 2GB)
   - Monitor resource usage

3. **Backups**:
   - Regularly backup the `./data/.openclaw` directory
   - Backup the `./data/clawd` workspace directory

4. **Updates**:
   - Regularly update the Docker image
   - Test updates in a staging environment first

## Important Notes

⚠️ **This is an experimental Docker image.**
- Not tested for production use
- May have bugs or incomplete features
- Created primarily for [Coolify](https://coolify.io) deployment
- Use at your own risk

## Links

- **Repository**: https://github.com/YAlmuzaini/openclaw.docker
- **Coolify**: https://coolify.io
- **OpenClaw**: https://github.com/openclaw/openclaw
- **Docker Hub**: https://hub.docker.com/r/almuzaini/openclaw
