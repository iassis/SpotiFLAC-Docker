# ==========================================
# Stage 1: The Builder (Compiles the Source)
# ==========================================
FROM golang:1.26-bookworm AS builder

# Define the version argument
ARG SPOTIFLAC_VERSION=v7.1.6

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libwebkit2gtk-4.1-dev \
    libglib2.0-dev \
    libnss3-dev \
    libdbus-1-dev \
    libasound2-dev \
    build-essential \
    pkg-config \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pnpm

# Install Wails CLI
RUN go install github.com/wailsapp/wails/v2/cmd/wails@latest
ENV PATH="/root/go/bin:${PATH}"

WORKDIR /build

# SMART CLONE: Try the tag, fallback to main if tag doesn't exist
RUN git clone https://github.com/afkarxyz/SpotiFLAC.git . && \
    (git checkout ${SPOTIFLAC_VERSION} || (echo "Tag ${SPOTIFLAC_VERSION} not found, falling back to main branch..." && git checkout main))

# Build the application
RUN wails build -platform linux/amd64 -clean -o SpotiFLAC -ldflags "-s -w"

# ==========================================
# Stage 2: The Runtime (The Efficient Container)
# ==========================================
# FIXED: Using the specific tracking tag for Debian 12
FROM jlesage/baseimage-gui:debian-12-v4

ENV APP_NAME="SpotiFLAC"

# Install Runtime Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.1-0 \
    libwebkit2gtk-4.0-37 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary
COPY --from=builder /build/build/bin/SpotiFLAC /app/SpotiFLAC
RUN chmod +x /app/SpotiFLAC

# Configure the auto-launch script
RUN echo "#!/bin/sh\n/app/SpotiFLAC" > /startapp.sh && \
    chmod +x /startapp.sh

ENV HOME=/config
