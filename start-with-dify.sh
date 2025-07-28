#!/bin/bash

# Dify連携用MCPサーバ起動スクリプト

set -e

echo "🚀 Starting Devin MCP Proxy for Dify integration..."

# 共有ネットワークが存在するか確認し、なければ作成
if ! docker network inspect dify-mcp-shared >/dev/null 2>&1; then
    echo "📡 Creating shared network: dify-mcp-shared"
    docker network create dify-mcp-shared
else
    echo "📡 Using existing network: dify-mcp-shared"
fi

# 環境変数チェック
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found. Copying from .env.example"
    cp .env.example .env
    echo "📝 Please edit .env file and set your DEVIN_API_KEY"
    exit 1
fi

# APIキーの存在確認
if ! grep -q "DEVIN_API_KEY=" .env || grep -q "DEVIN_API_KEY=your_api_key_here" .env; then
    echo "❌ DEVIN_API_KEY is not configured in .env file"
    echo "📝 Please set your DEVIN_API_KEY in .env file"
    exit 1
fi

# コンテナビルドと起動
echo "🔨 Building and starting MCP server..."
docker-compose up -d --build

# ヘルスチェック
echo "🔍 Waiting for server to be healthy..."
sleep 10

# ヘルスチェック実行
if curl -f http://localhost:8888/health >/dev/null 2>&1; then
    echo "✅ MCP Server is healthy and ready!"
    echo "🌐 External URL: http://localhost:8888"
    echo "🔗 Internal URL (for Dify): http://devin-mcp-proxy:8000/sse"
    echo ""
    echo "📋 Next steps:"
    echo "1. Configure Dify to use the shared network 'dify-mcp-shared'"
    echo "2. Add MCP server configuration in Dify"
    echo "3. See dify-integration.md for detailed setup instructions"
else
    echo "❌ Health check failed. Please check the logs:"
    docker logs devin-mcp-proxy
    exit 1
fi