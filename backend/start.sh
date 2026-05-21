#!/bin/sh
set -e

cd /app

# Railway provides $PORT for the externally-exposed service.
# Node uses $PORT (set by Railway), Python always uses 8000 internally.
export PYTHON_SERVICE_URL="http://localhost:8000"

echo "Starting Container"

# Start Python RAG service in the background
echo "Starting Python RAG service on port 8000..."
python python/api.py &
PY_PID=$!

# Start Node.js IMMEDIATELY so Railway's healthcheck (/health) passes right away.
# The Node /health endpoint works independently of Python.
# Python will finish initializing in the background — the /ask endpoint
# gracefully returns 503 until Python is ready.
echo "Python API starting in background (PID $PY_PID). Starting Node.js server on port ${PORT:-5000}..."
exec node server.js
