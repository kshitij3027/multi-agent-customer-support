#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$SCRIPT_DIR/.venv"

# Activate venv
source "$VENV/bin/activate"

# Kill any existing processes on our ports
for PORT in 8000 8001; do
  PID=$(lsof -ti :$PORT 2>/dev/null || true)
  if [ -n "$PID" ]; then
    echo "Killing existing process on port $PORT (PID $PID)..."
    kill $PID 2>/dev/null
    sleep 1
  fi
done

# Start returns agent A2A server in background (port 8001)
echo "Starting returns agent A2A server on port 8001..."
uvicorn returns_agent.agent:a2a_app --host localhost --port 8001 &
RETURNS_PID=$!
echo "$RETURNS_PID" > "$SCRIPT_DIR/.returns_agent.pid"

# Wait for returns agent to be ready
echo "Waiting for returns agent to be ready..."
for i in $(seq 1 30); do
  if curl -s http://localhost:8001/.well-known/agent-card.json > /dev/null 2>&1; then
    echo "Returns agent is ready!"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "ERROR: Returns agent failed to start within 30s"
    kill $RETURNS_PID 2>/dev/null
    exit 1
  fi
  sleep 1
done

# Start main agent in foreground (port 8000)
echo "Starting main customer support agent on port 8000..."
echo "Open http://localhost:8000 in your browser"
adk web --no-reload .

# When main agent exits (Ctrl+C), also stop returns agent
kill $RETURNS_PID 2>/dev/null
rm -f "$SCRIPT_DIR/.returns_agent.pid"
