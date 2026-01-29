# SpotiFLAC Docker 🎵

[![SpotiFLAC Auto-Update](https://github.com/iassis/SpotiFLAC-Docker/actions/workflows/sync-build.yml/badge.svg)](https://github.com/iassis/SpotiFLAC-Docker/actions/workflows/sync-build.yml)
![Upstream Version](https://img.shields.io/github/v/release/afkarxyz/SpotiFLAC?label=upstream%20version&color=blue)
![Image Size](https://img.shields.io/badge/docker%20size-840%20MB-orange)

A Dockerized version of the **SpotiFLAC** AppImage, designed to run smoothly on headless servers (like ZimaOS, Unraid, or Synology) via a web-browser interface.

> **Credits:** This is a containerized wrapper for the excellent tool by [afkarxyz/SpotiFLAC](https://github.com/afkarxyz/SpotiFLAC).

---

## ✨ Features
* **Web-Based GUI:** Access the full SpotiFLAC interface through any modern web browser.
* **True FLAC Downloads:** Fetches high-quality audio from Tidal, Qobuz, and Amazon Music.
* **No Account Required:** Works without needing a Spotify or streaming service login.
* **Auto-Updating:** Integrated GitHub Actions check for new upstream releases daily and rebuild the image automatically.
* **FFmpeg Included:** Comes pre-packaged with all necessary media dependencies.

---

## 🚀 Quick Start (Docker Compose)

Create a `docker-compose.yml` file and paste the following:

```yaml
services:
  spotiflac:
    image: ghcr.io/iassis/spotiflac:latest
    container_name: spotiflac
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC # Change to your timezone
    volumes:
      - ./config:/config       # App settings and internal data
      - ./downloads:/downloads # Map this to your music library
    ports:
      - 3001:3001 # Access the Web GUI at https://localhost:3004
    shm_size: "1gb"
    security_opt:
      - seccomp:unconfined
    restart: unless-stopped
```

1. Run `docker compose up -d`.
2. Open your browser and navigate to `https://YOUR_IP:3001`.
3. Note: Since the container uses a self-signed certificate for HTTPS, you will need to click "Advanced" and "Proceed" in your browser.

---

## ⚙️ Configuration
Inside the SpotiFLAC GUI settings, ensure you set the Download Folder to `/downloads` so that files are saved to your host machine's mapped volume. You will find the app under the Multimedia menu.

---

## 🤖 Automation
This repository uses GitHub Actions to stay current:

Daily Check: Every 24 hours, the `sync-build.yml` workflow checks for a new version tag in the official SpotiFLAC repository.

Auto-Build: If a new version is detected, it builds a new image using the latest AppImage and pushes it to this registry.

Tagging: Images are tagged with both `:latest` and the specific version number (e.g., `:v7.0.7`).

---

## ⚖️ Disclaimer
This project is for educational and private use only. SpotiFLAC is a third-party tool and is not affiliated with Spotify, Tidal, Qobuz, or Amazon Music. Users are responsible for ensuring compliance with local laws and streaming service terms of service.
