# netbird 0.77.1 for OpenWrt 25.x

[English](README.md) | [Русский](README.ru.md) | [Deutsch](README.de.md)

Standalone OpenWrt package extracted from [openwrt/packages `net/netbird`](https://github.com/openwrt/packages/tree/master/net/netbird) with the version bumped to upstream **[v0.77.1](https://github.com/netbirdio/netbird/releases/tag/v0.77.1)**.

Prebuilt `apk` packages are available in [Releases](../../releases).

## Why update

Upstream v0.76.0 fixes a **local privilege escalation** in the daemon ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)): the world-writable IPC socket accepted unauthenticated callers, letting any local user get root via the SSH-server feature. All versions < 0.76.0 are affected.

Also notable: nftables route-rule expression ordering fix, per-IP ACL fallback when `ipset` is unavailable.

## Install (OpenWrt 25.x / apk)

```sh
# download latest release for your arch
URL=$(curl -s https://api.github.com/repos/nagual2/luci-app-netbird/releases/latest \
  | grep -oE 'https://[^"]+x86_64\.apk' | head -1)
curl -L -o /tmp/netbird.apk "$URL"

# install or upgrade (keeps config)
apk add --allow-untrusted /tmp/netbird.apk
rm -f /tmp/netbird.apk

/etc/init.d/netbird enable && /etc/init.d/netbird start
netbird up        # register: setup key or SSO
netbird status
```

Or from a workstation with SSH access:

```sh
./scripts/install-apk.sh <router-host> x86_64            # x86_64
./scripts/install-apk.sh <router-host> aarch64_cortex-a53  # mediatek/filogic (e.g. Xiaomi AX3000T)
```

Supported architectures: **x86_64**, **aarch64_cortex-a53** (mediatek/filogic). Upgrading over the stock 25.12 package works; the procd init script and `/etc/config` files are preserved.

## Build from source

Requires Linux (or WSL2). The SDK is downloaded automatically:

```sh
./scripts/build-apk-sdk.sh                    # x86_64
SDK_URL=https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/openwrt-sdk-25.12.5-mediatek-filogic_gcc-14.3.0_musl.Linux-x86_64.tar.zst \
  ./scripts/build-apk-sdk.sh                  # aarch64_cortex-a53
```

Output goes to `dist/`. WSL note: run make with a clean PATH — Windows interop entries like `Program Files (x86)` break OpenWrt recipes (`syntax error near unexpected token '('`). The build script already handles this.

CI builds both architectures on every push to `main`; tagged pushes (`v*`) attach packages to a GitHub Release.

## Sync from upstream

The package tree mirrors `net/netbird` from the upstream `openwrt-25.12` branch:

```sh
./scripts/sync-from-upstream.sh
```

See [UPSTREAM.md](UPSTREAM.md) for the sync state and the open PR.

| Branch | Stock version | This repo |
|---|---|---|
| openwrt-25.12 | 0.73.2 | **0.77.1-1** |

## Tested

| Stage | Environment |
|---|---|
| Compile | OpenWrt SDK 25.12.5, x86_64 + mediatek/filogic (aarch64_cortex-a53) |
| Run | OpenWrt 25.12.4 x86_64 VM: upgrade 0.66.2 → 0.77.1, procd service running, CLI/daemon report 0.77.1 |

## License

BSD-3-Clause (netbird), GPL-2.0 (OpenWrt packaging) — see [NOTICE](NOTICE).
