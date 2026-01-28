# Clawdbot Docker Image

> ⚠️ **EXPERIMENTAL - NOT READY FOR PRODUCTION USE** ⚠️
> 
> This Docker image is experimental and was initially created to work with [Coolify](https://coolify.io). It may contain bugs, incomplete features, or other issues. Use at your own risk.

## Overview

Pre-built Docker image for deploying [Clawdbot Gateway](https://github.com/clawdbot/clawdbot) using Docker Compose, initially designed for deployment on [Coolify](https://coolify.io).

## Quick Start

### Using Docker Compose (Recommended for Coolify)

```bash
docker pull almuzaini/clawdbot:latest
```

Then use with the provided `docker-compose.yml` file. See the [repository](https://github.com/YAlmuzaini/clawdbot.docker) for full setup instructions.

### Direct Docker Run

```bash
docker run -d \
  -p 18789:18789 \
  -e CLAWDBOT_GATEWAY_TOKEN=your-token \
  -e GOG_KEYRING_PASSWORD=your-password \
  -v $(pwd)/.clawdbot:/home/node/.clawdbot \
  -v $(pwd)/clawd:/home/node/clawd \
  almuzaini/clawdbot:latest
```

## Features

- Pre-built Clawdbot Gateway image
- Includes baked-in binaries (gog, goplaces, wacli)
- Optimized for [Coolify](https://coolify.io) deployment
- Automatic token synchronization
- Health checks included

## Requirements

- Docker or Docker Compose
- Minimum 2GB RAM recommended
- [Coolify](https://coolify.io) (optional, but recommended)

## Documentation

For detailed setup instructions, deployment guides, and troubleshooting, visit:
- **Repository**: https://github.com/YAlmuzaini/clawdbot.docker
- **Coolify**: https://coolify.io
- **Clawdbot**: https://github.com/clawdbot/clawdbot

## Tags

- `latest` - Latest version (may be unstable)
- `2026.1.24-4` - Specific version tag

## Important Notes

⚠️ **This is an experimental image.**
- Not tested for production use
- May have bugs or incomplete features
- Created primarily for [Coolify](https://coolify.io) deployment
- Use at your own risk

## Support

For issues related to:
- **Docker image**: https://github.com/YAlmuzaini/clawdbot.docker/issues
- **Clawdbot itself**: https://github.com/clawdbot/clawdbot/issues
- **Coolify**: https://coolify.io/docs

## License

See the [Clawdbot repository](https://github.com/clawdbot/clawdbot) for license information.
