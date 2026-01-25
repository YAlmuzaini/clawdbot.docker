#!/bin/bash

# Script to build and publish Clawdbot Docker image to Docker Hub
# Usage: ./publish.sh [tag] [dockerhub-username]
# Example: ./publish.sh v1.0.0 myusername

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get tag from argument or use 'latest'
TAG=${1:-latest}
DOCKERHUB_USER=${2:-${DOCKERHUB_USERNAME:-yourusername}}

# Validate Docker Hub username
if [ "$DOCKERHUB_USER" == "yourusername" ]; then
    echo -e "${RED}Error: Please provide your Docker Hub username${NC}"
    echo "Usage: ./publish.sh [tag] [dockerhub-username]"
    echo "Example: ./publish.sh v1.0.0 myusername"
    echo "Or set DOCKERHUB_USERNAME environment variable"
    exit 1
fi

IMAGE_NAME="${DOCKERHUB_USER}/clawdbot"

echo -e "${GREEN}Building and publishing Clawdbot Docker image${NC}"
echo -e "Image: ${YELLOW}${IMAGE_NAME}:${TAG}${NC}"
echo ""

# Check if we're in the Clawdbot repository
if [ ! -f "package.json" ] || [ ! -f "pnpm-lock.yaml" ]; then
    echo -e "${RED}Error: This script must be run from the Clawdbot repository root${NC}"
    echo "Please clone the Clawdbot repository first:"
    echo "  git clone https://github.com/clawdbot/clawdbot.git"
    echo "  cd clawdbot"
    echo ""
    echo "Then copy the Dockerfile from this repository:"
    echo "  cp /path/to/clawdbot.docker/Dockerfile ."
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo -e "${YELLOW}Warning: Dockerfile not found in current directory${NC}"
    echo "Please copy the Dockerfile from the clawdbot.docker repository"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Check if logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}Not logged in to Docker Hub. Please login:${NC}"
    docker login
fi

echo -e "${GREEN}Step 1: Building image...${NC}"
docker build -t "${IMAGE_NAME}:${TAG}" .

if [ "$TAG" != "latest" ]; then
    echo -e "${GREEN}Step 2: Tagging as latest...${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"
fi

echo -e "${GREEN}Step 3: Testing image...${NC}"
echo "Verifying binaries are installed..."
docker run --rm "${IMAGE_NAME}:${TAG}" which gog > /dev/null && echo "✓ gog found" || echo "✗ gog not found"
docker run --rm "${IMAGE_NAME}:${TAG}" which goplaces > /dev/null && echo "✓ goplaces found" || echo "✗ goplaces not found"
docker run --rm "${IMAGE_NAME}:${TAG}" which wacli > /dev/null && echo "✓ wacli found" || echo "✗ wacli not found"

echo ""
echo -e "${GREEN}Step 4: Pushing to Docker Hub...${NC}"
docker push "${IMAGE_NAME}:${TAG}"

if [ "$TAG" != "latest" ]; then
    docker push "${IMAGE_NAME}:latest"
fi

echo ""
echo -e "${GREEN}✓ Successfully published ${IMAGE_NAME}:${TAG}${NC}"
echo ""
echo "Users can now use your image by setting:"
echo "  CLAWDBOT_IMAGE=${IMAGE_NAME}:${TAG}"
echo ""
echo "Or in docker-compose.yml:"
echo "  image: ${IMAGE_NAME}:${TAG}"
