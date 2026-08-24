#!/bin/sh
# Refresh package files from openwrt/packages net/netbird (sparse clone).
# Syncs from the openwrt-25.12 branch by default; override with UPSTREAM_REF.
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
WORKDIR=$(mktemp -d)
UPSTREAM_REF="${UPSTREAM_REF:-openwrt-25.12}"
trap 'rm -rf "$WORKDIR"' EXIT

cd "$WORKDIR"
git init -q
git remote add origin https://github.com/openwrt/packages.git
git config core.sparseCheckout true
mkdir -p .git/info
echo 'net/netbird' > .git/info/sparse-checkout
git pull --depth=1 -q origin "$UPSTREAM_REF"
UPSTREAM_COMMIT=$(git rev-parse HEAD)

rsync -a --delete \
  --exclude='.git/' \
  --exclude='build/' \
  --exclude='dist/' \
  --exclude='README.md' \
  --exclude='README.ru.md' \
  --exclude='README.de.md' \
  --exclude='SECURITY.md' \
  --exclude='SECURITY.ru.md' \
  --exclude='SECURITY.de.md' \
  --exclude='UPSTREAM.md' \
  --exclude='NOTICE' \
  --exclude='LICENSE' \
  --exclude='.gitignore' \
  --exclude='.gitattributes' \
  --exclude='.github/' \
  --exclude='scripts/' \
  net/netbird/ "$REPO_ROOT/"

echo "Synced net/netbird from openwrt/packages @ $UPSTREAM_COMMIT"
echo "Update PKG_VERSION/PKG_HASH in Makefile if needed, then UPSTREAM.md and READMEs."
