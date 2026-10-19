#!/bin/sh
# Checks that each checksum file was signed by Nouverse, and that every file it names beside it matches.
#
#   sh scripts/verify-sums.sh <dir>        every SHA256SUMS* in <dir>, each with its .sig, and the files they name
#
# The keys are the ones compiled into Nouride and embedded in its install.sh; the private repository's tests hold
# this copy to that one, so a key rotated there and not here fails a release there, before anything is built here.
# Nothing in this repository holds a secret: what is built and published here is only ever what these keys signed.
set -eu
dir="${1:?usage: verify-sums.sh <dir>}"

# >>> release keys
RELEASE_KEYS='-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEAnm2hXYQAFI/oKB065wPWCyew0ZxILlSkhE1KFK7cvBw=
-----END PUBLIC KEY-----'
# <<< release keys

openssl pkeyutl -help 2>&1 | grep -q -- '-rawin' || { echo "OpenSSL 3 is needed to check an Ed25519 signature" >&2; exit 1; }
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
printf '%s\n' "$RELEASE_KEYS" | awk -v dir="$work" '/BEGIN PUBLIC KEY/ { n++ } { print > (dir "/key" n ".pem") }'

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

found=0
for sums in "$dir"/SHA256SUMS*; do
  case "$sums" in *.sig) continue ;; esac
  [ -f "$sums" ] || continue
  found=1
  [ -f "$sums.sig" ] || { echo "$sums has no signature beside it" >&2; exit 1; }
  tr -d ' \n\r' < "$sums.sig" | openssl base64 -d -A > "$work/sig.bin"
  ok=0
  for key in "$work"/key*.pem; do
    if openssl pkeyutl -verify -pubin -inkey "$key" -rawin -in "$sums" -sigfile "$work/sig.bin" >/dev/null 2>&1; then ok=1; fi
  done
  [ "$ok" = 1 ] || { echo "$sums: the signature does not verify — not what Nouverse published" >&2; exit 1; }
  # Every file the list names that is here must match; one named and absent is another job's, and is skipped.
  while read -r want name; do
    name="${name#./}"; name="${name#\*}"
    [ -f "$dir/$name" ] || continue
    got="$(sha256_of "$dir/$name")"
    [ "$got" = "$want" ] || { echo "$name: checksum $got, but $(basename "$sums") says $want" >&2; exit 1; }
    echo "ok $name"
  done < "$sums"
  echo "signed: $(basename "$sums")"
done
[ "$found" = 1 ] || { echo "no SHA256SUMS* in $dir" >&2; exit 1; }
