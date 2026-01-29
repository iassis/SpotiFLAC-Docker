FROM ghcr.io/linuxserver/webtop:ubuntu-xfce

ARG SPOTIFLAC_VERSION=v7.0.6

LABEL org.opencontainers.image.source="https://github.com/iassis/SpotiFLAC-Docker"

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libnss3 \
    libasound2t64 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Use the dynamic variable in the download URL
RUN wget -O SpotiFLAC.AppImage "https://github.com/afkarxyz/SpotiFLAC/releases/download/${SPOTIFLAC_VERSION}/SpotiFLAC.AppImage" && \
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
