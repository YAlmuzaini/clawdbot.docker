# Published Docker Images

Your Clawdbot Docker image is published to Docker Hub:

**Repository:** https://hub.docker.com/r/almuzaini/clawdbot

## Available Tags

- `almuzaini/clawdbot:latest` - Latest version
- `almuzaini/clawdbot:2026.1.24-3` - Specific version

## Quick Usage

```bash
docker pull almuzaini/clawdbot:latest
docker run -d -p 18789:18789 \
  -e CLAWDBOT_GATEWAY_TOKEN=your-token \
  -e GOG_KEYRING_PASSWORD=your-password \
  -v $(pwd)/.clawdbot:/home/node/.clawdbot \
  -v $(pwd)/clawd:/home/node/clawd \
  almuzaini/clawdbot:latest
```

Or use the `docker-compose.yml` file with `CLAWDBOT_IMAGE=almuzaini/clawdbot:latest`.

## Updating

```bash
docker tag clawdbot:local almuzaini/clawdbot:latest
docker push almuzaini/clawdbot:latest
```
