#!/bin/bash
# Safe script to run onboard without being killed by terminal closure

CONTAINER_NAME=${1:-$(docker ps | grep clawdbot-gateway | awk '{print $1}' | head -1)}

if [ -z "$CONTAINER_NAME" ]; then
  echo "Error: Could not find clawdbot container"
  echo "Usage: $0 [container-name]"
  exit 1
fi

echo "Running onboard in container: $CONTAINER_NAME"
echo "This will run in the background. Check logs with: docker logs -f $CONTAINER_NAME"
echo ""

# Run onboard in background with output to log file
docker exec -d "$CONTAINER_NAME" sh -c "
  node --max-old-space-size=1536 dist/index.js onboard > /tmp/onboard.log 2>&1
  echo \$? > /tmp/onboard.exitcode
"

echo "Onboard started. Monitor progress with:"
echo "  docker exec $CONTAINER_NAME tail -f /tmp/onboard.log"
echo ""
echo "Check if it completed:"
echo "  docker exec $CONTAINER_NAME cat /tmp/onboard.exitcode"
echo "  (0 = success, non-zero = error)"
