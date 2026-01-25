#!/bin/bash
set -e

# Sync CLAWDBOT_GATEWAY_TOKEN from environment to config file if set
if [ -n "$CLAWDBOT_GATEWAY_TOKEN" ] && [ -f "/home/node/.clawdbot/clawdbot.json" ]; then
  echo "[entrypoint] Syncing CLAWDBOT_GATEWAY_TOKEN to config file..."
  node -e "
    const fs = require('fs');
    const configPath = '/home/node/.clawdbot/clawdbot.json';
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config.gateway && config.gateway.auth) {
        const envToken = process.env.CLAWDBOT_GATEWAY_TOKEN;
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
