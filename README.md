# Devin MCP プロキシサーバー

任意のMCPクライアントとDevin MCP APIをシームレスに統合するFastMCPベースのプロキシサーバーです。AIを活用したリポジトリ分析と質疑応答機能を提供します。

## 🚀 クイックスタート

### Dockerを使用（推奨）

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-username/devin-mcp-proxy.git
cd devin-mcp-proxy

# 2. 環境設定
cp .env.example .env
# .envファイルを編集してDEVIN_API_KEYを設定

# 3. ワンコマンドでデプロイ
./scripts/deploy.sh
```

### Pythonで直接実行

```bash
# 1. 依存関係をインストール
uv sync

# 2. 環境設定
cp .env.example .env
# .envファイルを編集してDEVIN_API_KEYを設定

# 3. サーバー起動
uv run python main.py
```

## 📋 機能

- **🔗 MCPプロトコル準拠**: 任意のMCPクライアント（Claude Desktop、Cursor、Clineなど）で動作
- **🤖 Devin統合**: DevinのAI駆動リポジトリ分析への直接アクセス
- **🐳 Docker対応**: プロダクション級設定での完全なコンテナ化
- **🔒 セキュア**: 非rootユーザー実行、環境変数管理、入力検証
- **📊 可観測性**: 組み込みヘルスチェック、包括的ログ機能
- **⚡ 高速**: 適切なエラーハンドリングを含む最適化された非同期実装
- **📱 簡単デプロイ**: ビルドとデプロイの自動化スクリプト

## 🏗️ アーキテクチャ

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   MCPクライアント │    │  Devin MCP       │    │   Devin MCP     │
│ (Claude等)      │───▶│  プロキシサーバー  │───▶│   APIサービス    │
│                 │    │  (このプロジェクト) │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

プロキシサーバーの動作：
1. クライアントからMCPツール呼び出しを受信
2. `ask_question`リクエストをDevin MCP APIに転送
3. 設定されたリポジトリに関するAI生成レスポンスを返却

## 🛠️ 前提条件

- **Docker & Docker Compose**（コンテナ化デプロイ用）
- **Python 3.10以降**（直接実行用）
- **有効なDevin APIキー**（全てのデプロイで必要）

## 📦 インストール

### オプション1: Dockerデプロイ

1. **クイックセットアップ**
   ```bash
   git clone https://github.com/your-username/devin-mcp-proxy.git
   cd devin-mcp-proxy
   cp .env.example .env
   # .envを編集: DEVIN_API_KEY=実際のAPIキー
   ./scripts/deploy.sh
   ```

2. **手動Docker**
   ```bash
   docker-compose up -d --build
   ```

3. **プロダクションデプロイ**
   ```bash
   # レジストリ用ビルド
   REGISTRY=your-registry.com ./scripts/build.sh v1.0.0
   
   # プロダクション環境でデプロイ
   docker-compose -f docker-compose.prod.yml up -d
   ```

### オプション2: ローカルPython

1. **UV のインストール**（未インストールの場合）
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source $HOME/.local/bin/env
   ```

2. **プロジェクトセットアップ**
   ```bash
   git clone https://github.com/your-username/devin-mcp-proxy.git
   cd devin-mcp-proxy
   uv sync
   cp .env.example .env
   # .envを編集: DEVIN_API_KEY=実際のAPIキー
   ```

3. **サーバー実行**
   ```bash
   uv run python main.py
   ```

## ⚙️ 設定

### 環境変数

| 変数名 | 必須 | デフォルト | 説明 |
|-------|------|-----------|------|
| `DEVIN_API_KEY` | ✅ | - | あなたのDevin APIキー |
| `REPO_NAME` | ❌ | `smartfnexta/pms` | クエリ対象のリポジトリ |

### リポジトリ設定

対象リポジトリを変更するには、`main.py`を編集：

```python
REPO_NAME = "your-org/your-repo"  # この行を変更
```

## 🔧 使用方法

### Difyとの連携

1. **DifyでMCPサーバーを追加**
   - Dify管理パネルでツール → MCPに移動
   - サーバーを追加: `http://localhost:8000/sse/`
   - プロトコルバージョン: `2025-03-26`

2. **ワークフローでの使用**
   - `ask_question`ツールを選択
   - リポジトリに関する質問を入力
   - コードベースに関するAI駆動の洞察を取得

### Claude Desktopとの連携

Claude Desktop設定に追加：

```json
{
  "mcpServers": {
    "devin-proxy": {
      "serverUrl": "http://localhost:8000/sse",
      "headers": {
        "Authorization": "Bearer オプション認証トークン"
      }
    }
  }
}
```

### 直接APIテスト

```bash
# サーバーエンドポイントのテスト
curl http://localhost:8000

# ヘルスチェック
curl http://localhost:8000/health
```

## 📊 監視

### ヘルスチェック

```bash
# Dockerヘルス状態
docker-compose ps

# 手動ヘルスチェック
curl -f http://localhost:8000 && echo "✅ 正常" || echo "❌ 異常"
```

### ログ

```bash
# Dockerログ
docker-compose logs -f devin-mcp-proxy

# タイムスタンプ付きログ
docker-compose logs -f --timestamps devin-mcp-proxy

# システムサービスログ（systemd使用時）
sudo journalctl -u devin-mcp-proxy -f
```

## 🚀 開発

### プロジェクト構成

```
devin-mcp-proxy/
├── main.py                 # メインサーバーアプリケーション
├── pyproject.toml          # Python依存関係（uv）
├── requirements.txt        # Python依存関係（pip）
├── Dockerfile              # コンテナ定義
├── docker-compose.yml      # ローカルデプロイ
├── .env.example           # 環境テンプレート
├── scripts/
│   ├── build.sh           # ビルド自動化
│   └── deploy.sh          # デプロイ自動化
├── CLAUDE.md              # Claude Code用ガイダンス
├── DOCKER.md              # Docker詳細ガイド
└── README.md              # このファイル
```

### ローカル開発

```bash
# 開発モードでインストール
uv sync --dev

# 自動リロード付き実行（開発用）
uv run python main.py

# テスト実行（利用可能な場合）
uv run pytest

# コードフォーマット
uv run black main.py
uv run isort main.py
```

### カスタムイメージのビルド

```bash
# カスタムタグでビルド
./scripts/build.sh v1.2.3

# 特定レジストリ用ビルド
REGISTRY=ghcr.io/your-org ./scripts/build.sh v1.2.3

# レジストリにプッシュ
docker push ghcr.io/your-org/devin-mcp-proxy:v1.2.3
```

## 🔒 セキュリティ

- **非root実行**: コンテナは`mcp`ユーザーで実行
- **環境分離**: APIキーは環境変数経由
- **入力検証**: 全ての入力は処理前に検証
- **最小攻撃面**: 必要なポートのみ公開
- **定期更新**: セキュリティパッチのためのベースイメージ更新

## 📚 ドキュメント

- **[DOCKER.md](DOCKER.md)** - 包括的なDockerデプロイガイド
- **[CLAUDE.md](CLAUDE.md)** - Claude Code用開発セットアップ
- **[プラン.md](プラン.md)** - 原実装計画
- **[要件.md](要件.md)** - 要件仕様

## 🐛 トラブルシューティング

### よくある問題

| 問題 | 原因 | 解決策 |
|------|------|--------|
| `Repository not found` | 無効なリポジトリ名または権限 | リポジトリの存在とアクセス可能性を確認 |
| `Invalid API key` | 間違ったまたは未設定のDevin APIキー | `.env`の`DEVIN_API_KEY`を確認 |
| `Port already in use` | ポート8000が使用中 | `docker-compose.yml`でポートを変更 |
| `Container unhealthy` | サービスが応答しない | ログを確認: `docker-compose logs devin-mcp-proxy` |

### デバッグコマンド

```bash
# コンテナステータス確認
docker-compose ps

# 詳細ログ表示
docker-compose logs --details devin-mcp-proxy

# コンテナ内でシェル実行
docker-compose exec devin-mcp-proxy bash

# 環境変数確認
docker-compose exec devin-mcp-proxy env | grep DEVIN

# MCP接続の手動テスト
docker-compose exec devin-mcp-proxy python -c "
import asyncio
from main import call_devin_mcp
print(asyncio.run(call_devin_mcp('このリポジトリについて教えて')))
"
```

### パフォーマンス調整

```bash
# メモリ制限を増加
echo "
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1.0'
" >> docker-compose.yml

# レプリカのスケール（ロードバランサーと併用）
docker-compose up -d --scale devin-mcp-proxy=3
```

## 🤝 貢献

1. リポジトリをフォーク
2. フィーチャーブランチを作成: `git checkout -b feature/your-feature`
3. 変更を加えて十分にテスト
4. コミット: `git commit -m "機能を追加"`
5. プッシュ: `git push origin feature/your-feature`
6. プルリクエストを開く

### 開発ガイドライン

- Python PEP 8スタイルガイドラインに従う
- 新機能にはテストを追加
- 変更に対してドキュメントを更新
- Dockerビルドが通ることを確認
- 複数のMCPクライアントでテスト

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## 🙏 謝辞

- **[FastMCP](https://gofastmcp.com)** - 優秀なMCPサーバーフレームワーク
- **[Devin AI](https://devin.ai)** - AI駆動開発プラットフォーム
- **[Model Context Protocol](https://modelcontextprotocol.io)** - 標準化されたAIツール統合
- **[Anthropic](https://anthropic.com)** - ClaudeとMCPエコシステム

## 📞 サポート

- **問題報告**: [GitHub Issues](https://github.com/your-username/devin-mcp-proxy/issues)
- **ディスカッション**: [GitHub Discussions](https://github.com/your-username/devin-mcp-proxy/discussions)
- **ドキュメント**: 詳細ガイドについては`docs/`フォルダを確認

---

<div align="center">

**❤️ [Claude Code](https://claude.ai/code)で作成**

[🏠 ホーム](https://github.com/your-username/devin-mcp-proxy) · [📚 ドキュメント](DOCKER.md) · [🐛 問題報告](https://github.com/your-username/devin-mcp-proxy/issues) · [💬 ディスカッション](https://github.com/your-username/devin-mcp-proxy/discussions)

</div>