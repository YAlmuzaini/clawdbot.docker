# Token Mismatch Issue - Root Cause and Prevention

## Why This Happened

1. **Two Token Sources:**
   - Environment variable: `CLAWDBOT_GATEWAY_TOKEN` (set in Coolify)
   - Config file: `/home/node/.clawdbot/clawdbot.json` (created by `onboard` command)

2. **The Problem:**
   - The `onboard` command generates its own token and saves it to the config file
   - The gateway reads the token from the config file, not the environment variable
   - When these don't match, you get `token_mismatch` errors

3. **When It Happens:**
   - Running `onboard` after setting `CLAWDBOT_GATEWAY_TOKEN` in Coolify
   - The `onboard` command doesn't check for existing environment variable tokens

## Solution Implemented

An entrypoint script (`docker-entrypoint.sh`) has been added that:
- Automatically syncs `CLAWDBOT_GATEWAY_TOKEN` from environment to config file on container startup
- Ensures the config file always matches the environment variable
- Runs before the gateway starts

## How to Avoid This in the Future

### Option 1: Use the Entrypoint Script (Recommended)

The Dockerfile now includes an entrypoint script that automatically syncs the token. After rebuilding the image, this will be automatic.

### Option 2: Manual Sync After Onboard

If you run `onboard`, immediately sync the token:

```bash
docker exec <container-name> sh -c 'node -e "const fs=require(\"fs\");const c=JSON.parse(fs.readFileSync(\"/home/node/.clawdbot/clawdbot.json\"));c.gateway.auth.token=process.env.CLAWDBOT_GATEWAY_TOKEN;fs.writeFileSync(\"/home/node/.clawdbot/clawdbot.json\",JSON.stringify(c,null,2));"'
```

### Option 3: Set Token Before Onboard

1. Set `CLAWDBOT_GATEWAY_TOKEN` in Coolify first
2. Then run `onboard` - but note: `onboard` may still generate its own token
3. Sync the token after (see Option 2)

### Option 4: Use Tokenized URL

Always use the tokenized URL to access the Control UI:
```
https://your-domain.com/?token=YOUR_TOKEN
```

This bypasses the config file token entirely.

## Best Practice

**Recommended workflow:**
1. Set `CLAWDBOT_GATEWAY_TOKEN` in Coolify environment variables
2. Deploy the container (entrypoint script will sync token automatically)
3. If you need to run `onboard`, sync the token afterward (or the entrypoint will fix it on next restart)

## For Existing Deployments

If you already have this issue:
1. The entrypoint script will fix it automatically on the next container restart
2. Or manually sync the token (see Option 2 above)
3. Or use the tokenized URL (see Option 4)
