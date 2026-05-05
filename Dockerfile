# ==========================================
# Stage 1: The Builder (Compiles the Source)
# ==========================================
FROM golang:1.21-bookworm AS builder

# Define the version argument
ARG SPOTIFLAC_VERSION=v7.1.6

# Install build dependencies
# We add curl to get the latest Node.js and updated GTK/WebKit libs
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    build-essential \
    pkg-config \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Wails CLI
RUN go install github.com/wailsapp/wails/v2/cmd/wails@latest

# Add the Go bin directory to the PATH so the 'wails' command is recognized
ENV PATH="/root/go/bin:${PATH}"

WORKDIR /build

# Clone the repo and checkout the specific version
RUN git clone https://github.com/afkarxyz/SpotiFLAC.git . && \
    git checkout ${SPOTIFLAC_VERSION}

# Build the application
# We use -skipbindings to speed up CI builds
RUN wails build -platform linux/amd64 -clean -o spotiflac

# ==========================================
# Stage 2: The Runtime (The Efficient Container)
# ==========================================
FROM jlesage/baseimage-gui:debian-12

ENV APP_NAME="SpotiFLAC"

# Install Runtime Dependencies
# Note: We use libwebkit2gtk-4.1-0 to match the builder stage
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary
# Wails puts the final binary in build/bin/
COPY --from=builder /build/build/bin/spotiflac /app/spotiflac

RUN chmod +x /app/spotiflac

# Configure the auto-launch script
RUN echo "#!/bin/sh\n/app/spotiflac" > /startapp.sh && \
    chmod +x /startapp.sh

ENV HOME=/config
