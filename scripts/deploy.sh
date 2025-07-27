#!/bin/bash

# Devin MCP Proxy Docker Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying Devin MCP Proxy${NC}"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: docker-compose not found${NC}"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env file not found. Copying from .env.example${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${RED}Please edit .env file and set your DEVIN_API_KEY before continuing${NC}"
        echo "Press Enter to continue after editing .env file..."
        read
    else
        echo -e "${RED}Error: .env.example not found${NC}"
        exit 1
    fi
fi

# Validate .env file
if ! grep -q "DEVIN_API_KEY=" .env || grep -q "DEVIN_API_KEY=$" .env || grep -q "DEVIN_API_KEY=your_devin_api_key_here" .env; then
    echo -e "${RED}Error: DEVIN_API_KEY not set in .env file${NC}"
    exit 1
fi

# Create logs directory
mkdir -p logs

# Pull latest images (if using registry)
echo -e "${GREEN}Pulling latest images...${NC}"
docker-compose pull || echo -e "${YELLOW}Skipping pull (building locally)${NC}"

# Build and start services
echo -e "${GREEN}Starting services...${NC}"
docker-compose up -d --build

# Wait for service to be ready
echo -e "${GREEN}Waiting for service to be ready...${NC}"
sleep 10

# Check service health
if docker-compose ps | grep -q "Up (healthy)"; then
    echo -e "${GREEN}Service is healthy and running!${NC}"
else
    echo -e "${YELLOW}Service is starting up, checking logs...${NC}"
    docker-compose logs devin-mcp-proxy
fi

echo ""
echo -e "${GREEN}Deployment completed!${NC}"
echo "Service URL: http://localhost:8000"
echo ""
echo "Commands:"
echo "  View logs:    docker-compose logs -f devin-mcp-proxy"
echo "  Stop service: docker-compose down"
echo "  Restart:      docker-compose restart"
echo "  Status:       docker-compose ps"