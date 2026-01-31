# Building and Publishing OpenClaw Docker Image

This guide explains how to build the OpenClaw Docker image and publish it to Docker Hub for others to use.

## Prerequisites

1. **Docker** installed and running
2. **Docker Hub account** (create one at https://hub.docker.com)
3. **OpenClaw source code** (clone from https://github.com/openclaw/openclaw)

## Building the Image

### Step 1: Clone the OpenClaw Repository

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

### Step 2: Copy Docker Files

Copy the Dockerfile and related files from this repository into the OpenClaw root:

```bash
# Copy Dockerfile
cp /path/to/openclaw.docker/Dockerfile .

# Copy .dockerignore (optional but recommended)
cp /path/to/openclaw.docker/.dockerignore .
```

### Step 3: Build the Image

Build the image with your Docker Hub username:

```bash
docker build -t yourusername/openclaw:latest .
```

Or build with a specific tag:

```bash
docker build -t yourusername/openclaw:v1.0.0 .
docker build -t yourusername/openclaw:latest .
```

### Step 4: Test the Image Locally

Before publishing, test that the image works:

```bash
# Test that the image runs
docker run --rm yourusername/openclaw:latest node dist/index.js --help

# Verify binaries are installed
docker run --rm yourusername/openclaw:latest which gog
docker run --rm yourusername/openclaw:latest which goplaces
docker run --rm yourusername/openclaw:latest which wacli
```

## Publishing to Docker Hub

### Step 1: Login to Docker Hub

```bash
docker login
```

Enter your Docker Hub username and password when prompted.

### Step 2: Push the Image

Push your image to Docker Hub:

```bash
# Push latest tag
docker push yourusername/openclaw:latest

# Push version tag
docker push yourusername/openclaw:v1.0.0
```

### Step 3: Verify on Docker Hub

1. Go to https://hub.docker.com
2. Navigate to your repository: `https://hub.docker.com/r/yourusername/openclaw`
3. Verify the image is listed with the correct tags

## Automated Publishing with GitHub Actions

You can automate the build and publish process using GitHub Actions. Create `.github/workflows/docker-publish.yml`:

```yaml
name: Build and Publish Docker Image

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

env:
  REGISTRY: docker.io
  IMAGE_NAME: yourusername/openclaw

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout OpenClaw repository
        uses: actions/checkout@v4
        with:
          repository: openclaw/openclaw
          fetch-depth: 0

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=semver,pattern={{major}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
          cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
```

**Setup GitHub Secrets:**
1. Go to your repository Settings → Secrets and variables → Actions
2. Add `DOCKER_USERNAME` with your Docker Hub username
3. Add `DOCKER_PASSWORD` with your Docker Hub access token (not password)

## Multi-Architecture Builds

To support multiple architectures (amd64, arm64), use Docker Buildx:

```bash
# Create a buildx builder
docker buildx create --name multiarch --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t yourusername/openclaw:latest \
  --push \
  .
```

## Updating the Image

When OpenClaw releases a new version:

1. **Update the source:**
   ```bash
   cd openclaw
   git pull origin main
   ```

2. **Rebuild the image:**
   ```bash
   docker build -t yourusername/openclaw:latest .
   docker build -t yourusername/openclaw:v1.1.0 .
   ```

3. **Push both tags:**
   ```bash
   docker push yourusername/openclaw:latest
   docker push yourusername/openclaw:v1.1.0
   ```

## Docker Hub Repository Settings

For better discoverability on Docker Hub:

1. **Add a description** in the repository settings
2. **Add tags** like: `openclaw`, `gateway`, `automation`, `docker`
3. **Link to documentation** (this README or the main OpenClaw docs)
4. **Add a README** on Docker Hub with quick start instructions

## Example Docker Hub README

```markdown
# OpenClaw Docker Image

Pre-built Docker image for OpenClaw Gateway.

## Quick Start

```bash
docker run -d \
  -p 18789:18789 \
  -v $(pwd)/.openclaw:/home/node/.openclaw \
  -v $(pwd)/clawd:/home/node/clawd \
  -e OPENCLAW_GATEWAY_TOKEN=your-token \
  yourusername/openclaw:latest
```

## Documentation

See the [full documentation](https://github.com/yourusername/openclaw.docker) for deployment instructions.
```

## Troubleshooting

### Build fails with "package.json not found"

Make sure you're building from the OpenClaw repository root, not from this directory.

### Build is slow

The first build will be slow. Subsequent builds will be faster due to Docker layer caching. Consider using BuildKit:

```bash
DOCKER_BUILDKIT=1 docker build -t yourusername/openclaw:latest .
```

### Push fails with "unauthorized"

Make sure you're logged in:
```bash
docker login
```

### Image is too large

The image includes build tools and source code. Consider using multi-stage builds to reduce size (though this may complicate the build process).

## Security Notes

- Never commit Docker Hub credentials to version control
- Use Docker Hub access tokens instead of passwords
- Regularly update the base image (`node:22-bookworm`) for security patches
- Scan images for vulnerabilities: `docker scan yourusername/openclaw:latest`
