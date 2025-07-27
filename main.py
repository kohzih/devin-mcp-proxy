import os
import json
import requests
from fastmcp import FastMCP
from dotenv import load_dotenv

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

@mcp.tool()
def ask_question(question: str) -> str:
    """
    Devin MCPのask_questionツールを呼び出してリポジトリに関する質問に回答します。
    
    Args:
        question: リポジトリに関する質問
        
    Returns:
        Devin MCPからの回答
    """
    try:
        # Devin MCP APIへのリクエスト準備
        url = f"{DEVIN_API_BASE_URL}/sse"
        headers = {
            "Authorization": f"Bearer {DEVIN_API_KEY}",
            "Content-Type": "application/json"
        }
        
        # リクエストボディを作成
        payload = {
            "mcp_sse_call_tool": {
                "arguments": json.dumps({
                    "repoName": REPO_NAME,
                    "question": question
                }),
                "tool_name": "ask_question"
            }
        }
        
        # Devin MCP APIを呼び出し
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        
        # レスポンスをチェック
        if response.status_code == 200:
            return response.text
        elif response.status_code == 401:
            return "Error: Invalid API key. Please check your DEVIN_API_KEY."
        elif response.status_code == 403:
            return "Error: Access forbidden. Please check your permissions."
        elif response.status_code == 404:
            return f"Error: Repository '{REPO_NAME}' not found."
        else:
            return f"Error: API request failed with status {response.status_code}: {response.text}"
            
    except requests.exceptions.Timeout:
        return "Error: Request timed out. Please try again later."
    except requests.exceptions.ConnectionError:
        return "Error: Unable to connect to Devin MCP API. Please check your internet connection."
    except requests.exceptions.RequestException as e:
        return f"Error: Request failed: {str(e)}"
    except json.JSONDecodeError as e:
        return f"Error: Invalid JSON in request: {str(e)}"
    except Exception as e:
        return f"Error: Unexpected error occurred: {str(e)}"

if __name__ == "__main__":
    print(f"Starting Devin Proxy MCP Server...")
    print(f"Target repository: {REPO_NAME}")
    print(f"API endpoint: {DEVIN_API_BASE_URL}")
    
    # SSEトランスポートでサーバーを起動
    mcp.run(transport="sse")