#!/bin/bash

echo "=== Starting Ubuntu Desktop for Render.com ==="

# Render assigns PORT dynamically, default to 6080 for local testing
PORT=${PORT:-6080}
echo "noVNC Port: $PORT"
echo "VNC Server Port: 5901"

# Clean up stale VNC locks and files
echo "[1/5] Cleaning up stale files..."
rm -rf /tmp/.X* /tmp/.x* 2>/dev/null || true
rm -rf /root/.vnc/*.pid /root/.vnc/*.log 2>/dev/null || true

# Create VNC password file (empty/no password)
echo "[2/5] Setting up VNC..."
mkdir -p /root/.vnc
touch /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Start VNC Server on display :1 (internal port 5901)
echo "[3/5] Starting VNC Server on :1 (port 5901)..."
vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE

# Wait for VNC to fully start and verify
echo "[4/5] Waiting for VNC to initialize..."
sleep 5

# Check if VNC is running
for i in 1 2 3 4 5; do
    if netstat -tuln 2>/dev/null | grep -q ":5901" || ss -tuln 2>/dev/null | grep -q ":5901"; then
        echo "     ✓ VNC Server listening on port 5901"
        break
    fi
    echo "     Waiting for VNC... attempt $i"
    sleep 2
done

# Generate SSL certificate for WebSocket
echo "[5/5] Generating SSL Certificate..."
openssl req -new -subj "/C=US/CN=localhost" -x509 -days 365 -nodes -out /tmp/novnc.pem -keyout /tmp/novnc.pem 2>/dev/null

echo ""
echo "============================================"
echo "=== Ubuntu Desktop Ready ==="
echo "URL: https://ubuntu-desktop-render.onrender.com/vnc.html"
echo "============================================"
echo ""

# Start noVNC websockify in foreground
# --heartbeat keeps connection alive
exec websockify --web=/usr/share/novnc/ --cert=/tmp/novnc.pem --heartbeat=30 $PORT localhost:5901
