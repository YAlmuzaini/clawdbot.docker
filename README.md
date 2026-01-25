# Clawdbot Docker Deployment for Coolify

This project contains the Docker configuration for deploying Clawdbot Gateway on Coolify.

## Overview

Clawdbot is a gateway service that can be deployed as a containerized application. This setup includes:

- **Dockerfile**: Builds the Clawdbot image with baked-in binaries
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
   - `CLAWDBOT_GATEWAY_TOKEN`: Generate with `openssl rand -hex 32`
   - `GOG_KEYRING_PASSWORD`: Generate with `openssl rand -hex 32` (if using Gmail)
   - `CLAWDBOT_IMAGE`: Set to your Docker Hub image (e.g., `yourusername/clawdbot:latest`)

   Edit `.env` and set all required values.

   - **Create a new Docker Compose resource** in Coolify
   - **Point to this repository** or upload the `docker-compose.yml` file
   - **Set environment variables** in Coolify's UI (they'll be auto-detected from the compose file)
     - Make sure `CLAWDBOT_IMAGE` points to your Docker Hub image
   - **Configure domain** (optional):
     - Assign a domain to the `clawdbot-gateway` service
     - Or use `SERVICE_URL_CLAWDBOT_GATEWAY` magic variable in your compose file
   - **Deploy**

   The compose file is configured to pull from Docker Hub by default. No source code needed!

### Option B: Building from Source

If you want to build the image yourself or customize it:

1. **Clone the Clawdbot Repository**

   ```bash
   git clone https://github.com/clawdbot/clawdbot.git
   cd clawdbot
   ```

2. **Copy Docker Files**

   Copy the Dockerfile from this repository:

   ```bash
   cp /path/to/clawdbot.docker/Dockerfile .
   ```

3. **Build the Image**

   ```bash
   docker build -t yourusername/clawdbot:latest .
   ```

4. **Update docker-compose.yml**

   Uncomment the `build:` section and comment out or remove the `image:` line:

   ```yaml
   services:
     clawdbot-gateway:
       # image: ${CLAWDBOT_IMAGE:-yourusername/clawdbot:latest}
       build:
         context: .
         dockerfile: Dockerfile
   ```

5. **Follow steps from Option A** to configure and deploy

For detailed build instructions, see [BUILD.md](./BUILD.md).

## Configuration

### Persistent Storage

The compose file defines two persistent volumes:

- **Config directory** (`./data/.clawdbot`): Gateway config, tokens, model auth profiles, skill configs
- **Workspace directory** (`./data/clawd`): Agent workspace, code, and artifacts

These directories are created automatically by Coolify using `is_directory: true`.

### Service Ports

- **Gateway**: Port `18789` (default)
- **Canvas** (optional): Port `18793` (only if running iOS/Android nodes)

### Environment Variables

All environment variables are automatically detected by Coolify from the compose file. Required variables (marked with `:?`) will be highlighted in the UI.

**Magic Environment Variables** (Coolify-specific):
- `SERVICE_URL_CLAWDBOT_GATEWAY`: Auto-generated URL for the gateway
- `SERVICE_FQDN_CLAWDBOT_GATEWAY`: Auto-generated FQDN
- `SERVICE_PASSWORD_CLAWDBOT_GATEWAY`: Auto-generated password

### Health Checks

The gateway service includes a health check that runs:
```bash
node dist/index.js health --token $CLAWDBOT_GATEWAY_TOKEN
```

## Using the CLI Service

The `clawdbot-cli` service is available for running commands. It uses the `cli` profile, so it won't start automatically.

To use it in Coolify, you can:
1. Run commands via Coolify's terminal/exec feature
2. Or temporarily enable the service

Example commands:

```bash
# Onboarding
docker compose run --rm clawdbot-cli onboard

# Channel setup (WhatsApp)
docker compose run --rm clawdbot-cli channels login

# Channel setup (Telegram)
docker compose run --rm clawdbot-cli channels add --channel telegram --token "<token>"

# Channel setup (Discord)
docker compose run --rm clawdbot-cli channels add --channel discord --token "<token>"
```

## Baked-in Binaries

The Dockerfile includes several pre-installed binaries:

- **gog**: Gmail CLI
- **goplaces**: Google Places CLI
- **wacli**: WhatsApp CLI

To add more binaries, edit the `Dockerfile` and add installation commands following the same pattern.

## Accessing the Gateway

### Via Domain (Recommended)

1. Assign a domain to the `clawdbot-gateway` service in Coolify
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
docker compose exec clawdbot-gateway which gog
docker compose exec clawdbot-gateway which goplaces
docker compose exec clawdbot-gateway which wacli
```

### Check Logs

```bash
docker compose logs -f clawdbot-gateway
```

Look for:
```
[gateway] listening on ws://0.0.0.0:18789
```

### Verify Persistence

After restarting, verify that your config and workspace persist:

```bash
docker compose exec clawdbot-gateway ls -la /home/node/.clawdbot
docker compose exec clawdbot-gateway ls -la /home/node/clawd
```

### Health Check Issues

If health checks are failing:
1. Verify `CLAWDBOT_GATEWAY_TOKEN` is set correctly
2. Check that the gateway is actually running
3. Review logs for errors

## Production Considerations

1. **Security**:
   - Use strong, randomly generated tokens
   - Keep `.env` file secure (never commit it)
   - Use HTTPS for domain access
   - Configure firewall rules appropriately

2. **Persistence**:
   - Ensure data directories are backed up
   - Consider using named volumes for additional safety
   - Regular backups of `~/.clawdbot` and `~/clawd`

3. **Resources**:
   - Monitor memory usage (especially with sandboxing enabled)
   - Adjust resource limits in Coolify if needed
   - Consider scaling for high-load scenarios

4. **Updates**:
   - Rebuild image when updating Clawdbot
   - Test updates in staging first
   - Backup data before major updates

## Publishing to Docker Hub

If you want to publish your own build of Clawdbot to Docker Hub for others to use:

1. **Build the image** (see [BUILD.md](./BUILD.md) for instructions)
2. **Push to Docker Hub:**
   ```bash
   docker login
   docker push yourusername/clawdbot:latest
   ```
3. **Update the default image** in `docker-compose.yml` and `.env.example` to point to your image

See [BUILD.md](./BUILD.md) for complete build and publish instructions.

## Additional Resources

- [Clawdbot Documentation](https://github.com/clawdbot/clawdbot)
- [Docker Setup Guide](/install/docker)
- [Hetzner VPS Guide](/platforms/hetzner)
- [Coolify Documentation](https://coolify.io/docs)
- [Docker Hub](https://hub.docker.com)

## Support

For issues specific to:
- **Clawdbot**: Check the [Clawdbot repository](https://github.com/clawdbot/clawdbot)
- **Coolify**: Check the [Coolify documentation](https://coolify.io/docs)
- **Docker**: Check the [Docker documentation](https://docs.docker.com/)
