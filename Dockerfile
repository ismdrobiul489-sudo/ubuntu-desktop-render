# ============================================
# Render.com - Ubuntu Desktop
# Browser-based Ubuntu Desktop using noVNC
# Port: Uses $PORT environment variable
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
# Add Mozilla PPA
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
    iproute2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Setup VNC Directory
# ============================================

RUN mkdir -p /root/.vnc && \
    touch /root/.Xauthority && \
    mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

# ============================================
# Create Startup Script inline (avoids CRLF)
# ============================================

RUN printf '#!/bin/bash\n\
    \n\
    echo "=== Starting Ubuntu Desktop ==="\n\
    \n\
    PORT=${PORT:-6080}\n\
    echo "Web Port: $PORT"\n\
    \n\
    # Cleanup\n\
    rm -rf /tmp/.X* /root/.vnc/*.pid 2>/dev/null || true\n\
    \n\
    # Setup VNC\n\
    mkdir -p /root/.vnc\n\
    echo "" | vncpasswd -f > /root/.vnc/passwd\n\
    chmod 600 /root/.vnc/passwd\n\
    \n\
    # Start VNC on display :1\n\
    echo "Starting VNC..."\n\
    vncserver :1 -geometry 1280x720 -depth 24 --I-KNOW-THIS-IS-INSECURE\n\
    \n\
    sleep 5\n\
    \n\
    # Show VNC status\n\
    echo "VNC processes:"\n\
    ps aux | grep -i vnc\n\
    echo "Listening ports:"\n\
    ss -tuln | grep -E "590|$PORT"\n\
    \n\
    # SSL cert\n\
    openssl req -new -x509 -days 365 -nodes -subj "/CN=localhost" \\\n\
    -out /tmp/cert.pem -keyout /tmp/cert.pem 2>/dev/null\n\
    \n\
    echo "Starting noVNC on port $PORT..."\n\
    echo "Access: /vnc.html"\n\
    \n\
    # Start websockify in foreground\n\
    exec websockify --web=/usr/share/novnc/ --cert=/tmp/cert.pem $PORT 127.0.0.1:5901\n\
    ' > /startup.sh && chmod +x /startup.sh

# ============================================
# Expose Port & Run
# ============================================

EXPOSE 10000

CMD ["/startup.sh"]
