# Sicherheitsrichtlinie für luci-app-netbird

**Sprachen:** [English](SECURITY.md) | [Русский](SECURITY.ru.md) | **Deutsch** (diese Seite)

## Melden von Sicherheitslücken

Wenn Sie eine Sicherheitsschwachstelle in diesem Repository entdecken, öffnen Sie bitte **kein** öffentliches Issue. Stattdessen:

1. Nutzen Sie [private GitHub Security Advisories](https://github.com/nagual2/luci-app-netbird/security/advisories/new)
2. Beschreiben Sie die Schwachstelle detailliert
3. Fügen Sie, falls zutreffend, Schritte zur Reproduktion bei
4. Planen Sie 90 Tage für eine Behebung vor der öffentlichen Offenlegung ein

Schwachstellen in NetBird selbst gehören zum Upstream: https://github.com/netbirdio/netbird/security

## Paketintegrität

Vorgefertigte `apk`-Artefakte werden von GitHub Actions aus den Quellen dieses Repositories erstellt. Vor der Installation prüfen:

```sh
# Prüfsumme wird mit jedem Release veröffentlicht
sha256sum netbird-0.77.1-r1_x86_64.apk

# Paketinhalt ansehen
apk manifest /tmp/netbird.apk        # auf dem Router
```

Die Pakete sind unsigniert (daher `--allow-untrusted`), da kein Feed-Signaturschlüssel existiert; nur über vertrauenswürdige Kanäle installieren — direkt aus den Releases dieses Repositories.

## Sicherheitshinweise für Benutzer

- Der Daemon läuft als root und öffnet einen lokalen IPC-Socket. NetBird-Versionen < 0.76.0 sind anfällig für lokale Privilegien-Eskalation ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)) — halten Sie das Paket aktuell.
- Das OpenWrt-Init-Skript setzt `NB_DISABLE_SSH_CONFIG=1` und verhindert damit, dass NetBird-Clients über das Mesh einen SSH-Server auf dem Router aktivieren. Diese Härtung nicht entfernen, außer die Auswirkungen sind klar.

## Sicherheitspraktiken für Mitwirkende

### Verhindern von Credential-Leakage

```bash
# Staged Changes auf Geheimnisse prüfen
git diff --cached | grep -iE "password|token|api.?key|secret|credential"

# Oder mit gitleaks (falls installiert)
gitleaks detect --staged
```

Keine Tokens in Git-URLs, Skripten oder CI-Logs einbetten. Router-Zugangsdaten gehören in `~/.ssh/config`, niemals in dieses Repository.

### Checkliste vor Pull Requests

- [ ] Keine Passwörter oder Tokens enthalten
- [ ] Keine Hostnamen oder IP-Adressen von Routern committet
- [ ] Keine Änderungen, die die Init-Skript-Härtung schwächen (env-Flags oben)
- [ ] `PKG_HASH` im Makefile entspricht dem Upstream-Tarball

## GitHub-Sicherheitskonfiguration

1. **Dependabot:** überwacht GitHub-Actions-Versionen (`.github/dependabot.yml`)
2. **Secret scanning:** empfohlen in den Repository-Einstellungen zu aktivieren
3. **Branch protection:** empfohlen für `main`

## Abhängigkeiten

Die Build-Pipeline nutzt ausschließlich den offiziellen OpenWrt-SDK-Tarball von downloads.openwrt.org und Standard-Build-Werkzeuge. Drittanbieter-Build-Abhängigkeiten werden durch dieses Repository nicht eingeführt.

---

Zuletzt aktualisiert: 2026-08-24
