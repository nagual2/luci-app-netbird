# netbird 0.77.1 für OpenWrt 25.x

[English](README.md) | [Русский](README.ru.md) | **Deutsch**

Eigenständiges OpenWrt-Paket, extrahiert aus [openwrt/packages `net/netbird`](https://github.com/openwrt/packages/tree/master/net/netbird), mit aktualisierter Version auf Upstream **[v0.77.1](https://github.com/netbirdio/netbird/releases/tag/v0.77.1)**.

Fertige `apk`-Pakete finden sich in den [Releases](../../releases).

## Warum aktualisieren?

Upstream v0.76.0 behebt eine **lokale Privilegien-Eskalation** im Daemon ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)): Der world-writable IPC-Socket akzeptierte jeden Aufrufer ohne Authentifizierung — jeder lokale Benutzer konnte über die SSH-Server-Funktion Root erlangen. Alle Versionen < 0.76.0 sind betroffen.

Außerdem: Fix der nftables-Ausdrucksreihenfolge bei Route-Rules sowie Fallback auf per-IP-ACLs, wenn `ipset` nicht verfügbar ist.

## Installation (OpenWrt 25.x / apk)

```sh
# neuestes Release für die eigene Architektur laden
URL=$(curl -s https://api.github.com/repos/nagual2/luci-app-netbird/releases/latest \
  | grep -oE 'https://[^"]+x86_64\.apk' | head -1)
curl -L -o /tmp/netbird.apk "$URL"

# Installation oder Upgrade (Konfiguration bleibt erhalten)
apk add --allow-untrusted /tmp/netbird.apk
rm -f /tmp/netbird.apk

/etc/init.d/netbird enable && /etc/init.d/netbird start
netbird up        # Registrierung: Setup-Key oder SSO
netbird status
```

Oder von einer Workstation per SSH:

```sh
./scripts/install-apk.sh <router-host> x86_64              # x86_64
./scripts/install-apk.sh <router-host> aarch64_cortex-a53  # mediatek/filogic (z. B. Xiaomi AX3000T)
```

Unterstützte Architekturen: **x86_64**, **aarch64_cortex-a53** (mediatek/filogic). Upgrade über das Standardpaket von 25.12 funktioniert; das procd-init script und die Dateien unter `/etc/config` bleiben erhalten.

## Selbst bauen

Benötigt Linux (oder WSL2). Das SDK wird automatisch geladen:

```sh
./scripts/build-apk-sdk.sh                    # x86_64
SDK_URL=https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/openwrt-sdk-25.12.5-mediatek-filogic_gcc-14.3.0_musl.Linux-x86_64.tar.zst \
  ./scripts/build-apk-sdk.sh                  # aarch64_cortex-a53
```

Ausgabe in `dist/`. Hinweis zu WSL: make mit sauberem PATH ausführen — Windows-Interop-Pfade wie `Program Files (x86)` brechen OpenWrt-Rezepte (`syntax error near unexpected token '('`). Das Build-Skript berücksichtigt das bereits.

Die CI baut beide Architekturen bei jedem Push nach `main`; Tag-Pushes (`v*`) hängen die Pakete an ein GitHub Release an.

## Synchronisation mit Upstream

Der Paketbaum spiegelt `net/netbird` aus dem Upstream-Zweig `openwrt-25.12`:

```sh
./scripts/sync-from-upstream.sh
```

Stand der Synchronisation und offener PR: siehe [UPSTREAM.md](UPSTREAM.md).

| Zweig | Standard-Version | Dieses Repo |
|---|---|---|
| openwrt-25.12 | 0.73.2 | **0.77.1-1** |

## Getestet

| Phase | Umgebung |
|---|---|
| Kompilieren | OpenWrt SDK 25.12.5, x86_64 + mediatek/filogic (aarch64_cortex-a53) |
| Ausführen | OpenWrt 25.12.4 x86_64 VM: Upgrade 0.66.2 → 0.77.1, procd-Dienst läuft, CLI/Daemon melden 0.77.1 |

## Lizenz

BSD-3-Clause (netbird), GPL-2.0 (OpenWrt-Paketierung) — siehe [NOTICE](NOTICE).
