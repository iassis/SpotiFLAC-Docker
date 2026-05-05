# ==========================================
# Stage 1: The Builder (Compiles the Source)
# ==========================================
FROM golang:1.26-bookworm AS builder

# Define the version argument
ARG SPOTIFLAC_VERSION=v7.1.6

# Install build dependencies
# 1. Core tools and GTK/WebKit headers
# 2. Node.js 20.x for frontend compilation
# 3. pnpm (Required by SpotiFLAC's wails.json)
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

# Add Go bin to PATH
ENV PATH="/root/go/bin:${PATH}"

WORKDIR /build

# Clone and Checkout the specific version
RUN git clone https://github.com/afkarxyz/SpotiFLAC.git . && \
    git checkout ${SPOTIFLAC_VERSION}

# Build the application
# -ldflags "-s -w" makes the binary smaller and more efficient
RUN wails build -platform linux/amd64 -clean -o spotiflac -ldflags "-s -w"

# ==========================================
# Stage 2: The Runtime (The Efficient Container)
# ==========================================
FROM jlesage/baseimage-gui:debian-12

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

# Copy the compiled binary from the builder
COPY --from=builder /build/build/bin/spotiflac /app/spotiflac
RUN chmod +x /app/spotiflac

# Configure the auto-launch script
RUN echo "#!/bin/sh\n/app/spotiflac" > /startapp.sh && \
    chmod +x /startapp.sh

ENV HOME=/config
