# ============================================
# Hugging Face Spaces - Ubuntu Desktop
# Browser-based Ubuntu Desktop using noVNC
# Port: 7860 (HF Spaces requirement)
# ============================================

FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ============================================
# Install GPG and basic tools first
# ============================================

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    gnupg \
    gpg-agent \
    ca-certificates \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Add Mozilla PPA and Install Firefox
# ============================================

RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

# ============================================
# Install Desktop Environment & Tools
# ============================================

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    openssl \
    firefox \
    xubuntu-icon-theme \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Setup VNC Directory
# ============================================

RUN mkdir -p /root/.vnc && \
    touch /root/.Xauthority

# ============================================
# Create Startup Script (Port 7860)
# ============================================

RUN echo '#!/bin/bash\n\
    set -e\n\
    \n\
    echo "=== Starting Ubuntu Desktop for Hugging Face Spaces ==="\n\
    echo "Port: 7860"\n\
    \n\
    # Clean up stale VNC locks\n\
    rm -rf /tmp/.X* /tmp/.x* 2>/dev/null || true\n\
    rm -rf /root/.vnc/*.pid 2>/dev/null || true\n\
    \n\
    # Start VNC Server on display :1 (port 5901)\n\
    echo "[1/3] Starting VNC Server..."\n\
    vncserver :1 -localhost no -SecurityTypes None -geometry 1280x720 --I-KNOW-THIS-IS-INSECURE\n\
    sleep 3\n\
    \n\
    # Generate SSL certificate for WebSocket\n\
    echo "[2/3] Generating SSL Certificate..."\n\
    openssl req -new -subj "/C=US/CN=localhost" -x509 -days 365 -nodes -out /tmp/novnc.pem -keyout /tmp/novnc.pem 2>/dev/null\n\
    \n\
    # Start noVNC websockify on port 7860 (HF Spaces requirement)\n\
    echo "[3/3] Starting noVNC on port 7860..."\n\
    websockify -D --web=/usr/share/novnc/ --cert=/tmp/novnc.pem 7860 localhost:5901\n\
    \n\
    echo "=== Desktop Ready ==="\n\
    echo "Access via: /vnc.html"\n\
    \n\
    # Keep container running\n\
    tail -f /dev/null\n\
    ' > /startup.sh && chmod +x /startup.sh

# ============================================
# Setup Permissions
# ============================================

RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# ============================================
# Expose Port & Run
# ============================================

EXPOSE 7860

CMD ["/startup.sh"]
