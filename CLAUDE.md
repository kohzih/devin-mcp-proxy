# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Devin MCP Proxy Server - A FastMCP-based proxy server that forwards ask_question requests to the Devin MCP API for the smartfnexta/pms repository.

## Development Commands

### Setup with uv (Recommended)
```bash
# Install dependencies with uv
uv sync

# Copy environment template and configure API key
cp .env.example .env
# Edit .env and add your DEVIN_API_KEY
```

### Setup with pip (Alternative)
```bash
# Install dependencies
pip install -r requirements.txt

# Copy environment template and configure API key
cp .env.example .env
# Edit .env and add your DEVIN_API_KEY
```

### Running the Server
```bash
# Start with uv (recommended)
uv run python main.py

# Or start with python directly
python3 main.py

# The server will run on SSE transport at http://localhost:8000
```

### Testing
```bash
# Test the server (requires MCP client)
# Use ask_question tool with any question about the smartfnexta/pms repository
```

## Architecture Overview

### Components
- **main.py**: FastMCP server with ask_question proxy tool
- **pyproject.toml**: Project configuration and dependencies for uv
- **requirements.txt**: Python dependencies (fastmcp, requests, python-dotenv)
- **.env**: Environment configuration (DEVIN_API_KEY)

### Data Flow
1. Client calls ask_question tool with question parameter
2. Server forwards request to Devin MCP API at https://mcp.devin.ai/sse
3. Fixed repository: smartfnexta/pms
4. Authentication via Bearer token from environment variable
5. Response returned to client

### Error Handling
- API authentication errors (401, 403)
- Network timeouts and connection errors
- JSON parsing errors
- Repository not found (404)
- Generic HTTP errors

## Environment Configuration
- `DEVIN_API_KEY`: Required Devin API key for authentication