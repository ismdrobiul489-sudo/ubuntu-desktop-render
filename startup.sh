#!/bin/bash

echo "=== Starting Ubuntu Desktop for Render.com ==="

# Get port from Render environment variable (default 10000)
PORT=${PORT:-10000}
echo "Port: $PORT"

# Clean up stale VNC locks
rm -rf /tmp/.X* /tmp/.x* 2>/dev/null || true
rm -rf /root/.vnc/*.pid 2>/dev/null || true

# Start VNC Server on display :1 (port 5901)
echo "[1/3] Starting VNC Server..."
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE
sleep 2

# Generate SSL certificate for WebSocket
echo "[2/3] Generating SSL Certificate..."
openssl req -new -subj "/C=US/CN=localhost" -x509 -days 365 -nodes -out /tmp/novnc.pem -keyout /tmp/novnc.pem 2>/dev/null

# Start noVNC websockify on dynamic PORT (foreground mode)
echo "[3/3] Starting noVNC on port $PORT..."
echo "=== Desktop Ready ==="
echo "Access via: https://your-app.onrender.com/vnc.html"

# Run websockify in foreground - keeps container alive
exec websockify --web=/usr/share/novnc/ --cert=/tmp/novnc.pem $PORT localhost:5901
