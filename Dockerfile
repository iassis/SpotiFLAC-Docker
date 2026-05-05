# ==========================================
# Stage 1: The Builder (Compiles the Source)
# ==========================================
FROM golang:1.21-bookworm AS builder

# Define the version argument
ARG SPOTIFLAC_VERSION=v7.1.6

# Install ALL potential build dependencies for Wails
# We include both 4.0 and 4.1 headers to prevent "Package not found" errors
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libwebkit2gtk-4.1-dev \
    libglib2.0-dev \
    build-essential \
    pkg-config \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Wails CLI
RUN go install github.com/wailsapp/wails/v2/cmd/wails@latest

# Ensure Go binaries are in the path
ENV PATH="/root/go/bin:${PATH}"

WORKDIR /build

# Clone and Checkout
RUN git clone https://github.com/afkarxyz/SpotiFLAC.git . && \
    git checkout ${SPOTIFLAC_VERSION}

# Build the application
# We use -trimpath and -ldflags to make the binary as small and efficient as possible
RUN wails build -platform linux/amd64 -clean -o spotiflac -ldflags "-s -w"

# ==========================================
# Stage 2: The Runtime (The Efficient Container)
# ==========================================
FROM jlesage/baseimage-gui:debian-12

ENV APP_NAME="SpotiFLAC"

# Install Runtime Dependencies
# We install both 4.0 and 4.1 runtime libraries to match the builder
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.0-37 \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary
COPY --from=builder /build/build/bin/spotiflac /app/spotiflac
RUN chmod +x /app/spotiflac

# Configure the auto-launch script
RUN echo "#!/bin/sh\n/app/spotiflac" > /startapp.sh && \
    chmod +x /startapp.sh

ENV HOME=/config
