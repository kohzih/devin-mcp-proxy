# Multi-stage build for smaller final image
FROM python:3.12-slim as builder

# Install uv for fast dependency resolution
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml .
COPY requirements.txt .

# Install dependencies in virtual environment
RUN uv venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN uv pip install -r requirements.txt

# Production stage
FROM python:3.12-slim as production

# Install security updates, curl for healthcheck, and clean up
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r mcp && useradd -r -g mcp -s /bin/bash mcp

# Set working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/venv /app/venv

# Copy application files
COPY main.py .
COPY .env.example .

# Change ownership to mcp user
RUN chown -R mcp:mcp /app

# Set PATH to include virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Switch to non-root user
USER mcp

# Expose port
EXPOSE 8000

# Health check - MCPサーバーの基本的な起動確認
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/sse || exit 1

# Set default environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Default command
CMD ["python", "main.py"]