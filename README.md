# Nouride Releases & Distribution

> Official binary releases, container images, and distribution repository for [Nouride](https://nouride.com).

[Nouride](https://nouride.com) is an ultra-lightweight, zero-bloat multi-agent AI engine in a single binary daemon. Built for servers, homelabs, and edge/mini devices (Raspberry Pi, Orange Pi, Geekom, NUC, LXC, Docker), it connects multiple chat platforms (Discord, Telegram, WhatsApp) to isolated AI agents with individual personas, shared skill pools, tool execution approval gates, cron scheduling, and a web dashboard.

- 🌐 **Website:** [nouride.com](https://nouride.com)
- 📖 **Documentation:** [nouride.com/docs](https://nouride.com/en/docs/start/what-is-nouride/)
- 🚀 **Getting Started:** [nouride.com/docs/start/first-run](https://nouride.com/en/docs/start/first-run/)
- 📦 **Docker Container:** `ghcr.io/nouverse/nouride:latest` — or `ghcr.io/nouverse/nouride-router:latest` with the Nougate AI Router built in

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

For the **Router edition** (bundled with the in-process Nougate LLM Gateway and Web Admin Console):

```bash
curl -fsSL https://get.nouride.com/install-bundle-router.sh | sudo sh
# or expose on LAN:
curl -fsSL https://get.nouride.com/install-bundle-router.sh | sudo sh -s -- --host 0.0.0.0
```

Once installed, open `http://127.0.0.1:18254/` on that machine — or `http://<your-ip>:18254/` if you
installed with `--host 0.0.0.0` — to complete setup. The first-run password is printed by the installer
and in the service log (`journalctl -u nouride | grep -A6 'Nouride is ready'`).

---

### 2. Docker Container

The official multi-arch container image (`linux/amd64` and `linux/arm64`) is published to GitHub Container Registry:

```bash
mkdir -p ~/nouride && cd ~/nouride
docker run -d \
  --name nouride \
  --restart unless-stopped \
  -p 18254:18254 \
  -v "$PWD/nouride:/app/.nouride" \
  ghcr.io/nouverse/nouride:latest

docker logs -f nouride          # the first-run password is printed here
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
      - ./nouride:/app/.nouride
```

#### Variant: Nougate AI Router

`nouride-router` is the same build **plus the Nougate AI Router in the same process** — model calls
answered from inside the daemon, with no second container and no network hop. Useful on a Pi, an LXC
container, or anywhere that has to answer without a gateway in front of it.

```bash
mkdir -p ~/nouride && cd ~/nouride
docker run -d \
  --name nouride \
  --restart unless-stopped \
  -p 18254:18254 \
  -p 18256:18256 \
  -v "$PWD/nouride:/app/.nouride" \
  ghcr.io/nouverse/nouride-router:latest
```

Docker Compose:

```yaml
services:
  nouride:
    image: ghcr.io/nouverse/nouride-router:latest
    container_name: nouride
    restart: unless-stopped
    ports:
      - "18254:18254"
      - "18256:18256"
    volumes:
      - ./nouride:/app/.nouride
```

In the Router edition (`ghcr.io/nouverse/nouride-router`), the in-process Nougate gateway is **enabled by default** on port `18256` and keeps its state — accounts, providers, `nougate.db` — in a folder of its own inside the same volume: `./nouride/nougate/data/`. Nothing else to mount. Its web admin console is available at `http://<your-ip>:18256/frontend/`.

Point a provider at it in `.nouride/config.toml`:

```toml
[providers.local]
kind = "openai"
base_url = "http://127.0.0.1:18256/openai/v1"   # or /anthropic/v1
```

To explicitly configure or switch it off, use `[nougate]` in `.nouride/config.toml` (or set `NOUGATE_IN_PROCESS=false` in the daemon's environment):

```toml
[nougate]
in_process = false
port = 18256
```

Use `:latest`. To update, pull it again and recreate the container — the volume keeps everything:

```bash
docker compose pull && docker compose up -d
```

To see which variant an image is without pulling it:

```bash
docker image inspect ghcr.io/nouverse/nouride-router:latest \
  --format '{{index .Config.Labels "tech.nouverse.nouride.edition"}}'
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

The Router variant ships the same four targets, named `nouride-router-*`:

| Platform | Architecture | C Library | Download |
|---|---|---|---|
| Linux | `x86_64` | glibc | [`nouride-router-linux-x64.tar.gz`](https://get.nouride.com/latest/nouride-router-linux-x64.tar.gz) |
| Linux | `aarch64` | glibc | [`nouride-router-linux-arm64.tar.gz`](https://get.nouride.com/latest/nouride-router-linux-arm64.tar.gz) |
| Linux (Alpine) | `x86_64` | musl | [`nouride-router-linux-x64-musl.tar.gz`](https://get.nouride.com/latest/nouride-router-linux-x64-musl.tar.gz) |
| Linux (Alpine) | `aarch64` | musl | [`nouride-router-linux-arm64-musl.tar.gz`](https://get.nouride.com/latest/nouride-router-linux-arm64-musl.tar.gz) |

Or let the installer fetch it:

```bash
curl -fsSL https://get.nouride.com/install.sh | sudo sh -s -- --variant router
```

> **Note on Alpine / Musl:** The `-musl` build requires `libstdc++` (`apk add libstdc++`).

SHA256 checksums are attached to every release — `SHA256SUMS` for the standard build,
`SHA256SUMS-router` for the Router variant.

---

## Contributing & Issues

The core engine is developed and maintained by Nouverse Technologies in an internal repository, while binary distributions and public community feedback are coordinated through this repository.

- **Found a bug or crash?** Please **[Open an Issue](https://github.com/nouverse/nouride-releases/issues)**. Include your OS version, architecture (`uname -m`), deployment method (native or Docker), and relevant terminal output.
- **Feature Proposals:** Have ideas for new homelab integrations, agent tools, or chat adapters? Open an issue with your proposal and rationale.
- **Security Inquiries:** For sensitive security concerns, reach out directly to security@nouverse.tech.

---

## Licence & Attribution

Nouride is powered by [Nouverse Technologies](https://nouverse.com). For full licensing details and architecture specifications, visit the official [documentation](https://nouride.com/en/docs/start/what-is-nouride/).
