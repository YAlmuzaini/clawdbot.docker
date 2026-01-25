# Immediate Debugging Steps

## 1. Check Why Container is Dying

```bash
# Get container name
docker ps -a | grep clawdbot

# Check exit code and reason
docker inspect <container-name> | grep -A 5 "State"

# Check logs for OOM or errors
docker logs <container-name> --tail 50

# Check system logs for OOM kills
dmesg | grep -i "oom\|killed" | tail -20
```

## 2. Check Memory Usage

```bash
# Check current memory usage
free -h

# Check Docker memory usage
docker stats --no-stream

# Check container memory limit (if any)
docker inspect <container-name> | grep -i memory
```

## 3. Run Onboard Safely (Won't Die on Terminal Close)

```bash
# Get container name
CONTAINER=$(docker ps | grep clawdbot-gateway | awk '{print $1}' | head -1)

# Run onboard in background (detached)
docker exec -d $CONTAINER sh -c "node --max-old-space-size=1536 dist/index.js onboard > /tmp/onboard.log 2>&1"

# Monitor progress
docker exec $CONTAINER tail -f /tmp/onboard.log

# Check if it's still running
docker exec $CONTAINER ps aux | grep "node.*onboard"

# Check exit code when done
docker exec $CONTAINER cat /tmp/onboard.exitcode 2>/dev/null || echo "Still running"
```

## 4. Alternative: Run Onboard with Lower Memory

```bash
# Limit Node.js memory to 1GB
docker exec -it $CONTAINER node --max-old-space-size=1024 dist/index.js onboard
```

## 5. Check What Onboard is Doing When It Crashes

```bash
# Run with verbose output to see where it fails
docker exec -it $CONTAINER node dist/index.js onboard --verbose 2>&1 | tee onboard-output.log
```

## 6. Check Coolify Resource Limits

1. Go to Coolify → Your Application → Settings
2. Look for "Resources" or "Limits" section
3. Check if memory limit is set too low
4. Increase if needed (recommend at least 2GB for onboard)

## Quick Fix: Run Onboard in Background

```bash
# This will run even if terminal closes
CONTAINER=$(docker ps | grep clawdbot-gateway | awk '{print $1}' | head -1)
docker exec -d $CONTAINER sh -c "nohup node --max-old-space-size=1536 dist/index.js onboard > /tmp/onboard.log 2>&1 &"
```

Then monitor:
```bash
docker exec $CONTAINER tail -f /tmp/onboard.log
```
