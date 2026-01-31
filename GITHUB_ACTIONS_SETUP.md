# GitHub Actions Setup for Docker Hub Publishing

## Yes, this will update your Docker Hub image! ✅

The workflow automatically builds for **both AMD64 and ARM64** and pushes to Docker Hub at `almuzaini/openclaw:latest` (and version tags).

## Required Setup

### 1. Create Docker Hub Access Token

1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name it: `github-actions-openclaw`
4. Set permissions: **Read & Write**
5. Copy the token (you'll only see it once!)

### 2. Add GitHub Secrets

1. Go to your repository: https://github.com/YAlmuzaini/openclaw.docker
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:

   **Secret 1:**
   - Name: `DOCKER_HUB_USERNAME`
   - Value: `almuzaini`

   **Secret 2:**
   - Name: `DOCKER_HUB_TOKEN`
   - Value: `[paste your Docker Hub access token from step 1]`

   **Secret 3 (if openclaw/openclaw is private):**
   - Name: `GH_PAT`
   - Value: `[your GitHub Personal Access Token with repo access]`
   - Note: Only needed if the source repo is private

## How to Trigger

### Option A: Push a Tag (Recommended)

```bash
cd /Users/almuzaini/Documents/CodeInfraTech/openclaw.docker
git tag v2026.1.24-3
git push origin v2026.1.24-3
```

This will:
- Build for AMD64 and ARM64
- Push to `almuzaini/openclaw:latest`
- Push to `almuzaini/openclaw:2026.1.24-3`
- Push to `almuzaini/openclaw:v2026.1.24-3`

### Option B: Manual Trigger (GitHub UI)

1. Go to **Actions** tab in your repository
2. Click **Build and Publish Docker Image**
3. Click **Run workflow**
4. Enter a tag (e.g., `2026.1.24-3`)
5. Click **Run workflow**

## What Gets Pushed

- **Tag**: `almuzaini/openclaw:latest` (always updated)
- **Version tags**: Based on your git tag (e.g., `v2026.1.24-3`)
- **Platforms**: Both `linux/amd64` and `linux/arm64`

## Verify It Worked

After the workflow completes:

```bash
# Check the image supports AMD64
docker manifest inspect almuzaini/openclaw:latest
```

You should see both `amd64` and `arm64` in the output.

## Troubleshooting

### "Authentication failed"
- Check that `DOCKER_HUB_TOKEN` is correct
- Make sure the token has **Read & Write** permissions

### "Repository not found" or "Permission denied"
- If `openclaw/openclaw` is private, you need `GH_PAT` secret
- Create a GitHub Personal Access Token with `repo` scope

### Build fails
- Check the Actions logs for specific errors
- Make sure the Dockerfile path is correct
