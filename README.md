# Nouride Releases & Distribution

> Official binary releases, container images, and distribution repository for [Nouride](https://nouride.com).

[Nouride](https://nouride.com) is an ultra-lightweight, zero-bloat multi-agent AI engine in a single binary daemon. Built for servers, homelabs, and edge/mini devices (Raspberry Pi, Orange Pi, Geekom, NUC, LXC, Docker), it connects multiple chat platforms (Discord, Telegram, WhatsApp) to isolated AI agents with individual personas, shared skill pools, tool execution approval gates, cron scheduling, and a web dashboard.

- 🌐 **Website:** [nouride.com](https://nouride.com)
- 📖 **Documentation:** [nouride.com/docs](https://nouride.com/en/docs/start/what-is-nouride/)
- 🚀 **Getting Started:** [nouride.com/docs/start/first-run](https://nouride.com/en/docs/start/first-run/)
- 📦 **Docker Container:** `ghcr.io/nouverse/nouride:latest`

---

## Installation & Quickstart

### 1. Automated Linux Install (Recommended)

Nouride runs as a standalone self-contained binary with its own embedded runtime. On any supported Linux machine (Debian, Ubuntu, RHEL, Alpine, Arch, Raspberry Pi OS), run:

```bash
curl -fsSL https://get.nouride.com/install.sh | sudo sh
```

To review the script before piping it to a shell:

```bash
curl -fsSL https://get.nouride.com/install.sh | less
```

By default, the installer binds the web dashboard to loopback (`127.0.0.1:18254`). To expose it across your local network immediately:

```bash
curl -fsSL https://get.nouride.com/install.sh | sudo sh -s -- --host 0.0.0.0
```

Once installed, visit `http://<your-ip>:18254/` in your browser to complete initial setup.

---

### 2. Docker Container

The official multi-arch container image (`linux/amd64` and `linux/arm64`) is published to GitHub Container Registry:

```bash
docker run -d \
  --name nouride \
  --restart unless-stopped \
  -p 18254:18254 \
  -v /srv/nouride/.nouride:/srv/nouride/.nouride \
  ghcr.io/nouverse/nouride:latest
```

Docker Compose:

```yaml
services:
  nouride:
    image: ghcr.io/nouverse/nouride:latest
    container_name: nouride
    restart: unless-stopped
    ports:
      - "18254:18254"
    volumes:
      - /srv/nouride/.nouride:/srv/nouride/.nouride
```

---

### 3. Standalone Binary Downloads

Standalone tarballs include the executable, built-in skills, example configuration, and web dashboard assets. You can download the latest release directly or browse specific versions on the [Releases](https://github.com/nouverse/nouride-releases/releases) page.

| Platform | Architecture | C Library | Download |
|---|---|---|---|
| Linux | `x86_64` | glibc | [`nouride-linux-x64.tar.gz`](https://get.nouride.com/latest/nouride-linux-x64.tar.gz) |
| Linux | `aarch64` | glibc | [`nouride-linux-arm64.tar.gz`](https://get.nouride.com/latest/nouride-linux-arm64.tar.gz) |
| Linux (Alpine) | `x86_64` | musl | [`nouride-linux-x64-musl.tar.gz`](https://get.nouride.com/latest/nouride-linux-x64-musl.tar.gz) |
| Linux (Alpine) | `aarch64` | musl | [`nouride-linux-arm64-musl.tar.gz`](https://get.nouride.com/latest/nouride-linux-arm64-musl.tar.gz) |

> **Note on Alpine / Musl:** The `-musl` build requires `libstdc++` (`apk add libstdc++`).

SHA256 checksums are attached to every release as `SHA256SUMS`.

---

## Contributing & Issues

The core engine is developed and maintained by Nouverse Technologies in an internal repository, while binary distributions and public community feedback are coordinated through this repository.

- **Found a bug or crash?** Please **[Open an Issue](https://github.com/nouverse/nouride-releases/issues)**. Include your OS version, architecture (`uname -m`), deployment method (native or Docker), and relevant terminal output.
- **Feature Proposals:** Have ideas for new homelab integrations, agent tools, or chat adapters? Open an issue with your proposal and rationale.
- **Security Inquiries:** For sensitive security concerns, reach out directly to security@nouverse.tech.

---

## Licence & Attribution

Nouride is powered by [Nouverse Technologies](https://nouverse.com). For full licensing details and architecture specifications, visit the official [documentation](https://nouride.com/en/docs/start/what-is-nouride/).
