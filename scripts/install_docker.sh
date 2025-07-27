#!/bin/bash
set -e

echo "🐳 Docker インストールスクリプト（WSL2 Ubuntu）"
echo "=========================================="

# 1. システム更新
echo "📦 システム更新中..."
sudo apt update

# 2. 前提パッケージインストール
echo "📦 前提パッケージインストール中..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. Docker GPGキー追加
echo "🔑 Docker GPGキー追加中..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. Dockerリポジトリ追加
echo "📝 Dockerリポジトリ追加中..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker Engine インストール
echo "🐳 Docker Engine インストール中..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Dockerサービス開始
echo "🚀 Dockerサービス開始中..."
sudo systemctl start docker
sudo systemctl enable docker

# 7. ユーザー権限設定
echo "👤 ユーザー権限設定中..."
sudo usermod -aG docker $USER

# 8. Docker Compose（従来版）インストール
echo "🔧 Docker Compose（従来版）インストール中..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 9. インストール確認
echo "✅ インストール確認中..."
docker --version
docker compose version
docker-compose --version

# 10. Hello World テスト
echo "🧪 Hello World テスト実行中..."
sudo docker run hello-world

echo ""
echo "🎉 Docker インストール完了！"
echo ""
echo "⚠️  重要: 現在のシェルセッションを再起動してください"
echo "   newgrp docker  # または新しいターミナルを開く"
echo ""
echo "次のステップ:"
echo "1. cd /home/kohzih/worksapce/devinmcp"
echo "2. cp .env.example .env"
echo "3. nano .env  # DEVIN_API_KEYを設定"
echo "4. ./scripts/deploy.sh"