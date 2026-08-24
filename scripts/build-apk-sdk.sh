#!/usr/bin/env bash
# Build netbird .apk for OpenWrt 25.12+ using the official SDK.
# The package tree lives in the repo root (mirrors net/netbird) and is copied
# into feeds/packages/net/netbird because golang-package.mk resolves its own
# include path relative to the feed layout.
#
# Usage:
#   ./scripts/build-apk-sdk.sh                       # x86_64 default
#   SDK_URL=... ./scripts/build-apk-sdk.sh           # custom target (aarch64 etc.)
#
# Note: run with a clean PATH inside WSL. Windows interop PATH entries like
# "Program Files (x86)" break inline `PATH=` assignments in OpenWrt recipes
# ("syntax error near unexpected token `('").

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDK_URL="${SDK_URL:-https://downloads.openwrt.org/releases/25.12.5/targets/x86/64/openwrt-sdk-25.12.5-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst}"

case "$ROOT" in
	/mnt/*)
		SDK_DIR="${SDK_DIR:-${HOME}/.cache/openwrt-sdk-netbird}"
		OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist}"
		;;
	*)
		SDK_DIR="${SDK_DIR:-$ROOT/build/sdk}"
		OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist}"
		;;
esac

log() { printf '[build-apk-sdk] %s\n' "$*"; }

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "Missing command: $1" >&2
		exit 1
	}
}

need_cmd tar
need_cmd make
need_cmd rsync
need_cmd curl
need_cmd zstd || true

mkdir -p "$(dirname "$SDK_DIR")"

# Download + extract SDK if missing (cache-friendly).
ARCHIVE="$SDK_DIR/../sdk.tar.zst"

on_error() {
	echo "--- DIAGNOSTICS ON FAILURE ---" >&2
	df -h /tmp . >&2 || true
	ls -la "$(dirname "$ARCHIVE")" >&2 || true
}
trap on_error ERR

if [ ! -d "$SDK_DIR" ]; then
	log "Downloading SDK..."
	rm -f "$ARCHIVE"
	if command -v curl >/dev/null 2>&1; then
		curl -fSL --retry 5 --retry-all-errors --connect-timeout 30 \
			-o "$ARCHIVE" "$SDK_URL" || {
			log "curl failed, trying wget..."
			wget -q --tries=3 --timeout=60 -O "$ARCHIVE" "$SDK_URL"
		}
	else
		wget -q --tries=3 --timeout=60 -O "$ARCHIVE" "$SDK_URL"
	fi
	SIZE=$(stat -c%s "$ARCHIVE" 2>/dev/null || stat -f%z "$ARCHIVE" 2>/dev/null || echo 0)
	[ "$SIZE" -gt 10000000 ] || {
		echo "Downloaded SDK too small ($SIZE bytes): $SDK_URL" >&2
		exit 1
	}
	log "SDK archive: $SIZE bytes"
	mkdir -p "$SDK_DIR"
	tar --zstd -xf "$ARCHIVE" -C "$SDK_DIR" --strip-components=1
fi
trap - ERR

log "Syncing netbird into SDK feeds/packages/net/netbird ..."
rm -rf "$SDK_DIR/feeds/packages/net/netbird"
rsync -a \
	--exclude .git \
	--exclude build \
	--exclude dist \
	--exclude scripts \
	--exclude .github \
	"$ROOT/" "$SDK_DIR/feeds/packages/net/netbird/"

cd "$SDK_DIR"

./scripts/feeds update base packages > /tmp/netbird-feeds.log 2>&1 || true
./scripts/feeds install golang >> /tmp/netbird-feeds.log 2>&1 || true
./scripts/feeds install -f netbird >> /tmp/netbird-feeds.log 2>&1 || true

cat > .config <<EOF
CONFIG_ALL_NONSHARED=n
CONFIG_ALL_KMODS=n
CONFIG_ALL=n
CONFIG_AUTOREMOVE=n
CONFIG_SIGNED_PACKAGES=n
CONFIG_PACKAGE_netbird=m
EOF

make defconfig > /dev/null
grep -q '^CONFIG_PACKAGE_netbird=m' .config || {
	echo "netbird is not enabled in .config" >&2
	exit 1
}

log "Compiling netbird ..."
env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	make package/netbird/compile -j"$(nproc 2>/dev/null || echo 2)" > /tmp/netbird-build.log 2>&1 \
	|| env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
		make package/netbird/compile -j1 V=s | tail -40

mkdir -p "$OUTPUT_DIR"
find bin/packages -name 'netbird*.apk' -exec cp -a {} "$OUTPUT_DIR/" \;

if ! ls "$OUTPUT_DIR"/netbird*.apk >/dev/null 2>&1; then
	echo "APK build failed: no output in $OUTPUT_DIR" >&2
	exit 1
fi

log "Built packages:"
ls -la "$OUTPUT_DIR"/netbird*.apk
