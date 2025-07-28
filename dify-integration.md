# Dify連携設定ガイド

## 前提条件
- DifyとMCPサーバが同じDockerネットワーク `dify-mcp-shared` に接続されている
- MCPサーバが正常に起動している（ポート8888で外部アクセス可能）

## Difyでの設定手順

### 1. Difyのdocker-compose.ymlにネットワーク追加
```yaml
# Difyのdocker-compose.ymlに以下を追加
networks:
  dify-mcp-shared:
    external: true
    name: dify-mcp-shared

# 各サービスにネットワークを追加
services:
  api:
    networks:
      - default
      - dify-mcp-shared
  # 他のサービスにも同様に追加
```

### 2. MCP設定
Difyの管理画面またはAPIで以下の設定を追加：

```json
{
  "devin-mcp-proxy": {
    "url": "http://devin-mcp-proxy:8000/sse",
    "headers": {},
    "timeout": 50,
    "sse_read_timeout": 50
  }
}
```

### 3. 利用可能なツール
- `ask_question`: smartfnexta/pmsリポジトリに関する質問への回答

### 4. 確認方法
```bash
# ネットワーク接続確認
docker network inspect dify-mcp-shared

# ヘルスチェック確認
curl http://localhost:8888/health

# コンテナ間通信確認（Difyコンテナ内から）
curl http://devin-mcp-proxy:8000/health
```

## トラブルシューティング

### ネットワーク接続エラー
```bash
# 共有ネットワーク作成
docker network create dify-mcp-shared

# コンテナを再起動
docker-compose down && docker-compose up -d
```

### ヘルスチェック失敗
- DEVIN_API_KEYが正しく設定されているか確認
- コンテナログを確認: `docker logs devin-mcp-proxy`