#!/bin/sh
# Download the latest netbird release from this repo and install via apk
# on an OpenWrt 25.12+ router. Never touches /etc config (conffiles kept).
#
# Usage:
#   ./scripts/install-apk.sh <router_host> [x86_64|aarch64_cortex-a53]
set -eu

HOST="${1:?Usage: $0 <router_host> [arch]}"
ARCH="${2:-x86_64}"

case "$ARCH" in
	x86_64) ARCH_DIR="x86_64" ;;
	aarch64_cortex-a53) ARCH_DIR="aarch64_cortex-a53" ;;
	*) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

echo "Fetching latest netbird apk ($ARCH) from GitHub Releases..."
URL=$(curl -s https://api.github.com/repos/nagual2/luci-app-netbird/releases/latest \
	| grep -oE "https://[^\"]+$ARCH/netbird-[^\"]+\.apk" | head -1)
[ -n "$URL" ] || { echo "No apk found for $ARCH" >&2; exit 1; }

REMOTE="/tmp/$(basename "$URL")"
echo "Downloading $(basename "$URL")..."
curl -sL -o "/tmp/$(basename "$URL")" "$URL"

echo "Uploading to root@$HOST ..."
scp -q -O "/tmp/$(basename "$URL")" "root@${HOST}:${REMOTE}"
rm -f "/tmp/$(basename "$URL")"

echo "Installing on router..."
ssh "root@${HOST}" "
	set -e
	apk add --allow-untrusted '$REMOTE'
	rm -f '$REMOTE'
	netbird version
	/etc/init.d/netbird enabled && /etc/init.d/netbird restart || true
"

echo "Done: netbird installed/upgraded on $HOST"
