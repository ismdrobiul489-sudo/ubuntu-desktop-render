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
# Create Startup Script
# Uses $PORT from Render (default 10000)
# ============================================

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# ============================================
# Expose Port
# ============================================

EXPOSE 10000

CMD ["/startup.sh"]
