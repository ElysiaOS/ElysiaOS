#!/usr/bin/env bash
set -euo pipefail

PKG_NAME="jsoncpp-1.9.6-3-x86_64.pkg.tar.zst"
ARCHIVE_URL="https://archive.archlinux.org/packages/.all/${PKG_NAME}"
TARGET_DIR="/usr/local/lib"
CONF_FILE="/etc/ld.so.conf.d/usr-local-lib.conf"

if [[ "$EUID" -ne 0 ]]; then
  echo "Error: This script must be run with root privileges (e.g., sudo $0)" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Checking for package..."
CACHE_MATCH="$(find /var/cache/pacman/pkg -name "jsoncpp-1.9.6-*" 2>/dev/null | head -n 1 || true)"

if [[ -n "$CACHE_MATCH" && -f "$CACHE_MATCH" ]]; then
  echo "--> Using cached package: $CACHE_MATCH"
  PKG_FILE="$CACHE_MATCH"
else
  echo "--> Downloading from Arch Linux Archive..."
  PKG_FILE="${TMP_DIR}/${PKG_NAME}"
  curl -fL "$ARCHIVE_URL" -o "$PKG_FILE"
fi

echo "==> Extracting shared library..."
bsdtar -xf "$PKG_FILE" -C "$TMP_DIR"

echo "==> Installing to ${TARGET_DIR}..."
install -d "$TARGET_DIR"
cp -L "$TMP_DIR/usr/lib/libjsoncpp.so.26" "$TARGET_DIR/libjsoncpp.so.26"
chmod 755 "$TARGET_DIR/libjsoncpp.so.26"

echo "==> Updating dynamic linker configuration..."
if ! grep -qsxF "$TARGET_DIR" /etc/ld.so.conf /etc/ld.so.conf.d/* 2>/dev/null; then
  echo "$TARGET_DIR" > "$CONF_FILE"
fi

cd /
ldconfig

echo "==> Verifying installation..."
if ldconfig -p | grep -F "libjsoncpp.so.26" | grep -q "/usr/local/lib"; then
  ldconfig -p | grep libjsoncpp.so.26
  echo "==> Success: libjsoncpp.so.26 is installed and registered"
else
  echo "Error: Dynamic linker failed to index ${TARGET_DIR}/libjsoncpp.so.26" >&2
  exit 1
fi
 
