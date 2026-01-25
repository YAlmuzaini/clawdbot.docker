# Debugging Container Crashes During Onboard

## Symptoms
- Container fails/turns down in the middle of `node dist/index.js onboard`
- Exit code 137 (SIGKILL - usually OOM)
- Terminal shuts down suddenly

## Debugging Steps

### 1. Check Container Logs
```bash
# Get the container name
docker ps -a | grep clawdbot

# Check logs for OOM or errors
docker logs <container-name> --tail 100

# Check for OOM killer messages
docker logs <container-name> 2>&1 | grep -i "oom\|killed\|memory"
```

### 2. Check System Memory
```bash
# Check available memory on the host
free -h

# Check Docker memory usage
docker stats --no-stream

# Check if OOM killer is active
dmesg | grep -i "oom\|killed" | tail -20
```

### 3. Check Container Resource Limits
```bash
# Check container resource limits
docker inspect <container-name> | grep -A 10 "Memory"

# Check if Coolify has set memory limits
# (Check in Coolify UI: Application Settings → Resources)
```

### 4. Check Onboard Process
```bash
# Run onboard with verbose output
docker exec <container-name> node dist/index.js onboard --verbose

# Or check what onboard is doing
docker exec <container-name> ps aux | grep node
```

### 5. Monitor Resource Usage During Onboard
```bash
# In one terminal, watch resources
watch -n 1 'docker stats --no-stream <container-name>'

# In another terminal, run onboard
docker exec <container-name> node dist/index.js onboard
```

## Common Causes

### 1. Out of Memory (OOM)
- **Symptom**: Exit code 137, container killed
- **Solution**: Increase memory limit in Coolify or reduce memory usage

### 2. Disk Space
- **Symptom**: "No space left on device"
- **Solution**: Clean up Docker images/volumes, increase disk space

### 3. Timeout
- **Symptom**: Process hangs then dies
- **Solution**: Increase timeout or check network connectivity

### 4. Signal Interruption
- **Symptom**: Process receives SIGTERM/SIGKILL
- **Solution**: Check if Coolify is restarting the container

## Solutions

### Increase Memory Limit
1. Go to Coolify → Your Application → Settings
2. Find "Resources" or "Limits" section
3. Increase memory limit (e.g., 2GB → 4GB)
4. Redeploy

### Run Onboard in Background/Detached Mode
```bash
# Use nohup to prevent terminal closure from killing the process
docker exec -d <container-name> sh -c "nohup node dist/index.js onboard > /tmp/onboard.log 2>&1 &"

# Check progress
docker exec <container-name> tail -f /tmp/onboard.log
```

### Run Onboard with Lower Memory Usage
```bash
# Set Node.js memory limit
docker exec <container-name> node --max-old-space-size=1024 dist/index.js onboard
```

### Check What Onboard is Doing
The onboard command might be:
- Downloading large files
- Installing dependencies
- Building something
- Processing large data

Check the logs to see where it's failing.
