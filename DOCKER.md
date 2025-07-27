# Docker配置ガイド

## 概要

このプロジェクトはDockerコンテナとして配置可能です。マルチステージビルドによる最適化とセキュリティを考慮した設計になっています。

## 前提条件

- Docker Engine 20.10以降
- Docker Compose v2.0以降
- 有効なDevin APIキー

## クイックスタート

### 1. 環境設定

```bash
# .envファイルを作成
cp .env.example .env

# APIキーを設定
nano .env
# DEVIN_API_KEY=your_actual_api_key_here
```

### 2. ビルドと起動

```bash
# 自動ビルドスクリプト使用
./scripts/build.sh

# または手動ビルド
docker build -t devin-mcp-proxy .

# 起動
docker-compose up -d
```

### 3. デプロイスクリプト使用

```bash
# 全自動デプロイ
./scripts/deploy.sh
```

## 詳細な設定

### 環境変数

| 変数名 | 必須 | デフォルト | 説明 |
|--------|------|------------|------|
| `DEVIN_API_KEY` | ✅ | - | Devin APIキー |
| `PYTHONUNBUFFERED` | ❌ | 1 | Python出力バッファリング無効 |

### ポート設定

- **8000**: MCPサーバのHTTPエンドポイント
- **8000/sse**: Server-Sent Eventsエンドポイント

### ボリューム

- `./logs:/app/logs`: ログファイル永続化（オプション）

## Docker Composeコマンド

### 基本操作

```bash
# サービス起動
docker-compose up -d

# ログ表示
docker-compose logs -f devin-mcp-proxy

# サービス停止
docker-compose down

# サービス再起動
docker-compose restart

# ステータス確認
docker-compose ps
```

### デバッグ

```bash
# コンテナ内でシェル実行
docker-compose exec devin-mcp-proxy bash

# ヘルスチェック手動実行
docker-compose exec devin-mcp-proxy python -c "import requests; print(requests.get('http://localhost:8000').status_code)"
```

## プロダクション環境での配置

### 1. レジストリへのプッシュ

```bash
# レジストリタグ付きビルド
REGISTRY=your-registry.com ./scripts/build.sh v1.0.0

# プッシュ
docker push your-registry.com/devin-mcp-proxy:v1.0.0
docker push your-registry.com/devin-mcp-proxy:latest
```

### 2. プロダクション用docker-compose

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  devin-mcp-proxy:
    image: your-registry.com/devin-mcp-proxy:latest
    container_name: devin-mcp-proxy
    ports:
      - "8000:8000"
    environment:
      - DEVIN_API_KEY=${DEVIN_API_KEY}
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### 3. リバースプロキシ設定（Nginx）

```nginx
# /etc/nginx/sites-available/devin-mcp-proxy
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # SSE specific settings
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
    }
}
```

## トラブルシューティング

### よくある問題

1. **API Key Error**
   ```bash
   # .envファイルの確認
   cat .env | grep DEVIN_API_KEY
   
   # コンテナ内の環境変数確認
   docker-compose exec devin-mcp-proxy env | grep DEVIN
   ```

2. **Port Binding Error**
   ```bash
   # ポート使用状況確認
   netstat -tulpn | grep 8000
   
   # ポート変更
   # docker-compose.ymlで "8001:8000" に変更
   ```

3. **Container Health Check Failing**
   ```bash
   # ヘルスチェックログ確認
   docker inspect devin-mcp-proxy | grep -A 10 "Health"
   
   # 手動ヘルスチェック
   curl http://localhost:8000
   ```

### ログ分析

```bash
# 詳細ログ
docker-compose logs --details devin-mcp-proxy

# エラーログのみ
docker-compose logs devin-mcp-proxy 2>&1 | grep -i error

# リアルタイムログ
docker-compose logs -f --tail=100 devin-mcp-proxy
```

## セキュリティ

- 非rootユーザー（mcp）での実行
- 最小権限の原則
- APIキーの環境変数管理
- 定期的なベースイメージ更新

## 監視

### ヘルスチェック

コンテナは30秒間隔でヘルスチェックを実行し、HTTPエンドポイントの応答を確認します。

### メトリクス

- コンテナリソース使用量
- アプリケーションログ
- レスポンス時間

## バックアップ

```bash
# 設定ファイルのバックアップ
tar -czf devin-mcp-backup-$(date +%Y%m%d).tar.gz .env docker-compose.yml

# ログのバックアップ
docker-compose exec devin-mcp-proxy tar -czf /tmp/logs-backup.tar.gz /app/logs
docker cp devin-mcp-proxy:/tmp/logs-backup.tar.gz ./
```