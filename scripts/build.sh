#!/bin/bash

# Devin MCP Proxy Docker Build Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="devin-mcp-proxy"
VERSION=${1:-latest}
REGISTRY=${REGISTRY:-""}

echo -e "${GREEN}Building Devin MCP Proxy Docker Image${NC}"
echo "Image: ${IMAGE_NAME}:${VERSION}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found. Copying from .env.example${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${RED}Please edit .env file and set your DEVIN_API_KEY${NC}"
    else
        echo -e "${RED}Error: .env.example not found${NC}"
        exit 1
    fi
fi

# Build the image
echo -e "${GREEN}Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:${VERSION} .

# Tag as latest if version is not latest
if [ "$VERSION" != "latest" ]; then
    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
fi

# If registry is provided, tag for registry
if [ ! -z "$REGISTRY" ]; then
    docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:${VERSION}
    docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:latest
    echo -e "${GREEN}Tagged for registry: ${REGISTRY}${NC}"
fi

echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "Available images:"
docker images | grep ${IMAGE_NAME}

echo ""
echo -e "${GREEN}To run the container:${NC}"
echo "  docker-compose up -d"
echo ""
echo -e "${GREEN}To push to registry (if configured):${NC}"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:latest"