#!/bin/bash

echo "🔍 Devin MCP Proxy サーバー診断スクリプト"
echo "================================================"

# 基本情報確認
echo "📋 基本情報確認"
echo "現在時刻: $(date)"
echo "作業ディレクトリ: $(pwd)"
echo "ユーザー: $(whoami)"
echo ""

# Docker状態確認
echo "🐳 Docker状態確認"
echo "Docker version: $(docker --version 2>/dev/null || echo 'Docker not available')"
echo "Docker compose version: $(docker-compose --version 2>/dev/null || echo 'docker-compose not available')"
echo ""

# サービス状態確認
echo "📊 サービス状態確認"
docker-compose ps
echo ""

# ログ確認
echo "📝 最新ログ（最後の20行）"
docker-compose logs --tail=20 devin-mcp-proxy
echo ""

# ポート確認
echo "🔌 ポート使用状況"
echo "ポート8000の使用状況:"
netstat -tulpn 2>/dev/null | grep :8000 || ss -tulpn 2>/dev/null | grep :8000 || echo "ポート8000は使用されていません"
echo ""

# 環境変数確認
echo "🔧 環境変数確認"
if [ -f .env ]; then
    echo ".envファイル存在: ✅"
    echo "DEVIN_API_KEY設定状況:"
    if grep -q "DEVIN_API_KEY=" .env && ! grep -q "DEVIN_API_KEY=$" .env && ! grep -q "your_devin_api_key_here" .env; then
        echo "  ✅ DEVIN_API_KEYが設定済み"
    else
        echo "  ❌ DEVIN_API_KEYが未設定または無効"
    fi
else
    echo ".envファイル: ❌ 存在しません"
fi
echo ""

# コンテナ内環境変数確認
echo "🔍 コンテナ内環境変数確認"
if docker-compose ps | grep -q "Up"; then
    echo "コンテナ内のAPI KEY設定:"
    docker-compose exec -T devin-mcp-proxy env | grep DEVIN || echo "DEVIN_API_KEY変数が見つかりません"
else
    echo "コンテナが起動していません"
fi
echo ""

# ネットワーク接続テスト
echo "🌐 ネットワーク接続テスト"
echo "localhost:8000への接続テスト:"
curl -v --connect-timeout 5 http://localhost:8000 2>&1 | head -10
echo ""

# FastMCPエンドポイントテスト
echo "⚡ FastMCPエンドポイントテスト"
echo "SSEエンドポイント(/sse/)への接続テスト:"
curl -v --connect-timeout 5 http://localhost:8000/sse/ 2>&1 | head -10
echo ""

# コンテナヘルスチェック
echo "🏥 コンテナヘルスチェック"
if docker-compose ps | grep -q "Up"; then
    echo "コンテナヘルス状態:"
    docker inspect $(docker-compose ps -q devin-mcp-proxy) | grep -A 10 '"Health"' || echo "ヘルスチェック情報なし"
else
    echo "コンテナが起動していません"
fi
echo ""

# プロセス確認
echo "🔄 プロセス確認"
if docker-compose ps | grep -q "Up"; then
    echo "コンテナ内プロセス:"
    docker-compose exec -T devin-mcp-proxy ps aux | head -10
else
    echo "コンテナが起動していません"
fi
echo ""

# ディスク容量確認
echo "💾 ディスク容量確認"
df -h . | head -2
echo ""

# 推奨アクション
echo "🔧 推奨アクション"
echo "1. コンテナが停止している場合:"
echo "   docker-compose up -d"
echo ""
echo "2. APIキーが未設定の場合:"
echo "   cp .env.example .env"
echo "   nano .env  # DEVIN_API_KEYを設定"
echo ""
echo "3. ポートが使用中の場合:"
echo "   docker-compose down"
echo "   # 他のプロセスを停止してから"
echo "   docker-compose up -d"
echo ""
echo "4. ログを詳細確認:"
echo "   docker-compose logs -f devin-mcp-proxy"
echo ""
echo "5. コンテナ再起動:"
echo "   docker-compose restart devin-mcp-proxy"
echo ""
echo "6. 完全リセット:"
echo "   docker-compose down"
echo "   docker-compose up -d --build"