import os
import asyncio
from fastmcp import FastMCP
from dotenv import load_dotenv
from mcp import ClientSession, StdioServerParameters
from mcp.client.sse import sse_client

# 環境変数を読み込み
load_dotenv()

# MCPサーバーを初期化
mcp = FastMCP(name="devin-proxy-mcp")

# Devin API設定
DEVIN_API_BASE_URL = "https://mcp.devin.ai"
DEVIN_API_KEY = os.getenv("DEVIN_API_KEY")
REPO_NAME = "smartfnexta/pms"

if not DEVIN_API_KEY:
    raise ValueError("DEVIN_API_KEY environment variable is required")

async def call_devin_mcp(question: str) -> str:
    """
    Devin MCP APIを正しい方法で呼び出す非同期関数
    """
    server_url = f"{DEVIN_API_BASE_URL}/sse"
    headers = {"Authorization": f"Bearer {DEVIN_API_KEY}"}
    
    try:
        async with sse_client(server_url, headers=headers) as (read, write):
            async with ClientSession(read, write) as session:
                await session.initialize()
                
                result = await session.call_tool(
                    "ask_question",
                    arguments={
                        "repoName": REPO_NAME,
                        "question": question
                    }
                )
                
                return str(result.content[0].text) if result.content else "No response from Devin MCP"
                
    except Exception as e:
        return f"Error: {str(e)}"

@mcp.tool()
async def ask_question(question: str) -> str:
    """
    Devin MCPのask_questionツールを呼び出してリポジトリに関する質問に回答します。
    
    Args:
        question: リポジトリに関する質問
        
    Returns:
        Devin MCPからの回答
    """
    try:
        # 直接非同期関数を呼び出し
        return await call_devin_mcp(question)
    except Exception as e:
        return f"Error: Unexpected error occurred: {str(e)}"

# ヘルスチェック用のリソース
@mcp.resource("health")
async def health_check():
    """
    ヘルスチェック用リソース
    Difyとの連携やDocker healthcheckで使用
    """
    try:
        # 基本的なサーバー状態チェック
        if not DEVIN_API_KEY:
            return {
                "status": "unhealthy",
                "error": "DEVIN_API_KEY not configured"
            }
        
        return {
            "status": "healthy",
            "service": "devin-mcp-proxy", 
            "version": "1.0.0",
            "repo": REPO_NAME
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": f"Service unhealthy: {str(e)}"
        }

if __name__ == "__main__":
    print(f"Starting Devin Proxy MCP Server...")
    print(f"Target repository: {REPO_NAME}")
    print(f"API endpoint: {DEVIN_API_BASE_URL}")
    
    # SSEトランスポートでサーバーを起動
    mcp.run(transport="sse", host="0.0.0.0", port=8000)