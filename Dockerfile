# Use a base image with a Web GUI (Ubuntu XFCE)
FROM ghcr.io/linuxserver/webtop:ubuntu-xfce
LABEL org.opencontainers.image.source="https://github.com/iassis/SpotiFLAC-Docker"

# Set environment variables
ENV TITLE=SpotiFLAC

# Install dependencies
# UPDATED: Changed libasound2 to libasound2t64 for Ubuntu 24.04 compatibility
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libnss3 \
    libasound2t64 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Setup application directory
WORKDIR /app

# Download the specific AppImage version requested
# We extract it to avoid FUSE issues inside Docker
RUN wget -O SpotiFLAC.AppImage "https://github.com/afkarxyz/SpotiFLAC/releases/download/v7.0.7/SpotiFLAC.AppImage" && \
    chmod +x SpotiFLAC.AppImage && \
    ./SpotiFLAC.AppImage --appimage-extract && \
    rm SpotiFLAC.AppImage && \
    mv squashfs-root spotiflac

# Create a Desktop shortcut for easy access in the Web interface
RUN mkdir -p /usr/share/applications && \
    echo "[Desktop Entry]\n\
Version=1.0\n\
Type=Application\n\
Name=SpotiFLAC\n\
Comment=Spotify Downloader\n\
Exec=/app/spotiflac/AppRun\n\
Icon=utilities-terminal\n\
Path=/app/spotiflac\n\
Terminal=false\n\
Categories=AudioVideo;" > /usr/share/applications/spotiflac.desktop && \
    chmod +x /usr/share/applications/spotiflac.desktop

# Ensure permissions are correct for the default user (abc)
RUN chown -R abc:abc /app
