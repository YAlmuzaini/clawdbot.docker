# Published Docker Images

Your OpenClaw Docker image is published to Docker Hub:

**Repository:** https://hub.docker.com/r/almuzaini/openclaw

## Available Tags

- `almuzaini/openclaw:latest` - Latest version
- `almuzaini/openclaw:2026.1.24-3` - Specific version

## Quick Usage

```bash
docker pull almuzaini/openclaw:latest
docker run -d -p 18789:18789 \
  -e OPENCLAW_GATEWAY_TOKEN=your-token \
  -e GOG_KEYRING_PASSWORD=your-password \
  -v $(pwd)/.openclaw:/home/node/.openclaw \
  -v $(pwd)/clawd:/home/node/clawd \
  almuzaini/openclaw:latest
```

Or use the `docker-compose.yml` file with `OPENCLAW_IMAGE=almuzaini/openclaw:latest`.

## Updating

```bash
docker tag openclaw:local almuzaini/openclaw:latest
docker push almuzaini/openclaw:latest
```
