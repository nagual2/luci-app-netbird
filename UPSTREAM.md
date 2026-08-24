# Sync from openwrt/packages

This tree mirrors `net/netbird` from https://github.com/openwrt/packages.

## Remotes

| Remote | URL |
|--------|-----|
| `origin` | https://github.com/nagual2/luci-app-netbird.git |
| `upstream` | https://github.com/openwrt/packages.git |

```bash
git fetch upstream
git log -1 --oneline upstream/openwrt-25.12
```

## Refresh package files (WSL)

```bash
./scripts/sync-from-upstream.sh
```

The script sparse-clones `net/netbird` from the upstream `openwrt-25.12` branch and rsyncs it into the repo root.
**Excluded from rsync** (never deleted): `.git/`, `build/`, `dist/`, `scripts/`, `.github/`, README*, NOTICE, UPSTREAM.md, SECURITY*, LICENSE.

After sync:

1. Update `PKG_VERSION`/`PKG_HASH` in `Makefile` if a newer upstream release is wanted (or keep the synced one).
2. Update the sync table in `UPSTREAM.md` and in all three `README*` files.
3. Commit on a `sync/upstream-YYYY-MM-DD` branch; merge to `main`.

## Current sync

| Field | Value |
|-------|-------|
| Upstream branch | `openwrt-25.12` |
| Upstream package version before bump | 0.73.2 ([PR #29863](https://github.com/openwrt/packages/pull/29863)) |
| This repo version | 0.77.1-1 (`PKG_VERSION:=0.77.1`, `PKG_RELEASE:=1`) |
| Upstream PR | [openwrt/packages#30370 — netbird: update to 0.77.1](https://github.com/openwrt/packages/pull/30370) |
| Last sync | 2026-08-24 |
