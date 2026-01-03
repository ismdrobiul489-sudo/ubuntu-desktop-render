#!/bin/bash

echo "=== Starting Ubuntu Desktop for Render.com ==="

# Render assigns PORT dynamically, default to 6080 for local testing
PORT=${PORT:-6080}
echo "noVNC Port: $PORT"
echo "VNC Server Port: 5901"

# Clean up stale VNC locks
rm -rf /tmp/.X* /tmp/.x* 2>/dev/null || true
rm -rf /root/.vnc/*.pid 2>/dev/null || true

# Start VNC Server on display :1 (internal port 5901)
echo "[1/3] Starting VNC Server on :1 (port 5901)..."
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE
sleep 2

# Generate SSL certificate for WebSocket
echo "[2/3] Generating SSL Certificate..."
openssl req -new -subj "/C=US/CN=localhost" -x509 -days 365 -nodes -out /tmp/novnc.pem -keyout /tmp/novnc.pem 2>/dev/null

# Start noVNC websockify - bridges HTTP on $PORT to VNC on 5901
echo "[3/3] Starting noVNC on port $PORT -> VNC 5901..."
echo ""
echo "=== Desktop Ready ==="
echo "Access: https://your-app.onrender.com/vnc.html"
echo ""

# Run websockify in foreground - bridges web traffic to VNC
# $PORT is what Render exposes externally, 5901 is internal VNC
exec websockify --web=/usr/share/novnc/ --cert=/tmp/novnc.pem $PORT localhost:5901
