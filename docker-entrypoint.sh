#!/bin/bash
set -e

# Sync OPENCLAW_GATEWAY_TOKEN from environment to config file if set
if [ -n "$OPENCLAW_GATEWAY_TOKEN" ] && [ -f "/home/node/.openclaw/openclaw.json" ]; then
  echo "[entrypoint] Syncing OPENCLAW_GATEWAY_TOKEN to config file..."
  node -e "
    const fs = require('fs');
    const configPath = '/home/node/.openclaw/openclaw.json';
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config.gateway && config.gateway.auth) {
        const envToken = process.env.OPENCLAW_GATEWAY_TOKEN;
        if (envToken && config.gateway.auth.token !== envToken) {
          config.gateway.auth.token = envToken;
          fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
          console.log('[entrypoint] Updated config token to match environment variable');
        }
      }
    }
  "
fi

# Execute the original command
exec "$@"
