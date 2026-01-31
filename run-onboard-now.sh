#!/bin/bash
# Quick script to run onboard safely on the current container

CONTAINER="62faf524609d"

echo "Running onboard in container: $CONTAINER"
echo "This will run in the background and won't die if terminal closes."
echo ""

# Run onboard in background with memory limit
docker exec -d "$CONTAINER" sh -c "
  node --max-old-space-size=1536 dist/index.js onboard > /tmp/onboard.log 2>&1
  echo \$? > /tmp/onboard.exitcode
"

echo "✅ Onboard started in background!"
echo ""
echo "Monitor progress with:"
echo "  docker exec $CONTAINER tail -f /tmp/onboard.log"
echo ""
echo "Check if still running:"
echo "  docker exec $CONTAINER ps aux | grep onboard"
echo ""
echo "Check exit code when done:"
echo "  docker exec $CONTAINER cat /tmp/onboard.exitcode"
