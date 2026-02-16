#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Kill returns agent if PID file exists
if [ -f "$SCRIPT_DIR/.returns_agent.pid" ]; then
  PID=$(cat "$SCRIPT_DIR/.returns_agent.pid")
  if kill -0 "$PID" 2>/dev/null; then
    echo "Stopping returns agent (PID $PID)..."
    kill "$PID"
  fi
  rm -f "$SCRIPT_DIR/.returns_agent.pid"
fi

# Kill any remaining processes on ports 8000/8001
for PORT in 8000 8001; do
  PID=$(lsof -ti :$PORT 2>/dev/null)
  if [ -n "$PID" ]; then
    echo "Stopping process on port $PORT (PID $PID)..."
    kill $PID 2>/dev/null
  fi
done

echo "All services stopped."
