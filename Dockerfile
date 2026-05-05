# ==========================================
# Stage 1: The Builder (Compiles the Source)
# ==========================================
FROM golang:1.21-bookworm AS builder

# Define the version argument (defaults to v7.1.6 if run manually)
ARG SPOTIFLAC_VERSION=v7.1.6

# Install build dependencies for Wails (Go + Node + GTK dev libs)
RUN apt-get update && apt-get install -y \
    npm \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    build-essential \
    pkg-config

# Install the Wails CLI (The tool that builds the app)
RUN go install github.com/wailsapp/wails/v2/cmd/wails@latest

WORKDIR /build

# Clone the repo AND checkout the specific version tag
RUN git clone https://github.com/afkarxyz/SpotiFLAC.git . && \
    git checkout ${SPOTIFLAC_VERSION}

# Build the application
RUN wails build -platform linux/amd64 -clean -o spotiflac

# ==========================================
# Stage 2: The Runtime (The Efficient Container)
# ==========================================
# We use 'jlesage/baseimage-gui' which is optimized for single-app containers
FROM jlesage/baseimage-gui:debian-12

# Set the name of the application for the window manager
ENV APP_NAME="SpotiFLAC"

# Install Runtime Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libwebkit2gtk-4.0-37 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy ONLY the compiled binary from the builder stage
COPY --from=builder /build/build/bin/spotiflac /app/spotiflac

# Grant execution permissions
RUN chmod +x /app/spotiflac

# Configure the container to launch SpotiFLAC automatically
RUN echo "#!/bin/sh\n/app/spotiflac" > /startapp.sh && \
    chmod +x /startapp.sh

# Environment variables for the app
ENV HOME=/config
