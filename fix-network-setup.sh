#!/bin/bash

echo "🔧 Fixing Docker network setup for Dify-MCP integration..."

# Step 1: Stop existing containers
echo "📦 Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Step 2: Remove existing network with incorrect labels
echo "🗑️  Removing existing network..."
docker network rm dify-mcp-shared 2>/dev/null || true

# Step 3: Create network correctly
echo "🌐 Creating shared network correctly..."
docker network create dify-mcp-shared

# Step 4: Verify network creation
echo "✅ Verifying network..."
docker network ls | grep dify-mcp-shared
docker network inspect dify-mcp-shared --format '{{.Name}}: {{.Driver}}'

# Step 5: Start containers with fixed configuration
echo "🚀 Starting containers..."
docker-compose up -d --build

# Step 6: Verify deployment
echo "🔍 Checking container status..."
docker ps | grep devin-mcp-proxy

echo "🏥 Testing health endpoint..."
sleep 5
curl -s http://localhost:8888/health | jq . 2>/dev/null || curl -s http://localhost:8888/health

echo ""
echo "✅ Setup completed!"
echo "📋 Next steps:"
echo "1. Configure Dify to use the shared network"  
echo "2. Use URL: http://devin-mcp-proxy:8000/sse"