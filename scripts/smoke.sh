#!/bin/sh
# Starts a release tarball's daemon where it was unpacked and checks it answers as the release it says it is.
#
#   sh scripts/smoke.sh <tarball> <version> <edition>      e.g. nouride-linux-x64.tar.gz 0.7.20 basic
#
# Run on the platform the tarball is for — a native runner, or an Alpine container for a musl build — so what is
# checked is the binary as an install would run it, not a cross-compiled file that was never started.
set -eu
tarball="${1:?usage: smoke.sh <tarball> <version> <edition>}"
version="${2:?}"
edition="${3:?}"
port="${SMOKE_PORT:-18300}"

dir="$(mktemp -d)"
cleanup() { [ -n "${pid:-}" ] && kill "$pid" 2>/dev/null; rm -rf "$dir"; }
trap cleanup EXIT
tar -xzf "$tarball" -C "$dir"
[ -x "$dir/nouride" ] || { echo "no executable nouride in $tarball" >&2; exit 1; }
for part in dashboard skills config.example.toml; do
  [ -e "$dir/$part" ] || { echo "$tarball lacks $part" >&2; exit 1; }
done

said="$("$dir/nouride" --version)"
echo "--version: $said"
case "$said" in *"$version"*) ;; *) echo "--version says '$said', not $version" >&2; exit 1 ;; esac

# Its own install root beside the binary, as install.sh lays it out; no config, so a first boot.
(cd "$dir" && HOST=127.0.0.1 PORT="$port" LOG_LEVEL=info ./nouride start > "$dir/daemon.log" 2>&1) &
pid=$!
health=""
for _ in $(seq 1 60); do
  health="$(curl -fsS "http://127.0.0.1:$port/health" 2>/dev/null || true)"
  case "$health" in *'"version"'*) case "$health" in *'"starting"'*) ;; *) break ;; esac ;; esac
  sleep 1
done
echo "/health: $health"
case "$health" in *"\"version\":\"$version\""*) ;; *) echo "/health did not report version $version" >&2; tail -20 "$dir/daemon.log" >&2; exit 1 ;; esac
case "$health" in *"\"edition\":\"$edition\""*) ;; *) echo "/health did not report edition $edition" >&2; exit 1 ;; esac

# The CLI finds this install from beside the binary, and talks to the daemon.
(cd "$dir" && NOURIDE_URL="http://127.0.0.1:$port" ./nouride status) > "$dir/status.txt" 2>&1 || { cat "$dir/status.txt" >&2; echo "nouride status failed" >&2; exit 1; }
head -5 "$dir/status.txt"

# A clean stop: SIGTERM, and gone within the drain.
kill -TERM "$pid"
for _ in $(seq 1 45); do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
if kill -0 "$pid" 2>/dev/null; then echo "still running 45 s after SIGTERM" >&2; exit 1; fi
pid=""
if grep -q '"level":"error"' "$dir/daemon.log"; then echo "error lines in the log:" >&2; grep '"level":"error"' "$dir/daemon.log" | head -5 >&2; exit 1; fi
echo "smoke: $tarball ok ($edition $version)"
