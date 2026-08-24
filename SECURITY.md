# Security Policy for luci-app-netbird

**Languages:** **English** (this page) | [Русский](SECURITY.ru.md) | [Deutsch](SECURITY.de.md)

## Reporting Security Vulnerabilities

If you discover a security vulnerability in this repository, please **do not** open a public issue. Instead:

1. Use [GitHub private security advisories](https://github.com/nagual2/luci-app-netbird/security/advisories/new) for this repository
2. Provide a detailed description of the vulnerability
3. Include steps to reproduce (if applicable)
4. Allow 90 days for a fix before public disclosure

Vulnerabilities in NetBird itself should be reported upstream: https://github.com/netbirdio/netbird/security

## Package Integrity

Prebuilt `apk` artifacts are produced by GitHub Actions from the sources in this repository. Verify before installing:

```sh
# checksum published with each release
sha256sum netbird-0.77.1-r1_x86_64.apk

# inspect package contents
apk manifest /tmp/netbird.apk        # on the router
```

The packages are unsigned (`--allow-untrusted` is required) because there is no feed signing key; only install them over trusted channels (direct download from this repo's Releases).

## Security Notes for Users

- The daemon runs as root and exposes a local IPC socket. Versions < 0.76.0 of NetBird are vulnerable to local privilege escalation ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)) — keep the package updated.
- The OpenWrt init script sets `NB_DISABLE_SSH_CONFIG=1`, which prevents NetBird clients from enabling an SSH server on the router through the mesh — do not remove this hardening unless you understand the impact.

## Security Best Practices for Contributors

### Preventing Credential Leakage

```bash
# Check staged changes for secrets
git diff --cached | grep -iE "password|token|api.?key|secret|credential"

# Or use gitleaks (if installed)
gitleaks detect --staged
```

Do NOT embed tokens in git URLs, scripts, or CI logs. Router credentials belong in `~/.ssh/config`, never in this repository.

### Code Review Checklist

Before creating a pull request, ensure:

- [ ] No passwords or tokens included
- [ ] No router hostnames or IP addresses committed
- [ ] No changes that weaken the init-script hardening (env flags above)
- [ ] `PKG_HASH` in the Makefile matches the upstream tarball

## GitHub Security Configuration

This repository has the following security settings:

1. **Dependabot:** watches GitHub Actions versions (`.github/dependabot.yml`)
2. **Secret scanning:** recommended to enable in repo settings
3. **Branch protection:** recommended for `main`

## Dependencies

The build pipeline uses only the official OpenWrt SDK tarball from downloads.openwrt.org and standard build tools. No third-party build dependencies are introduced by this repository.

---

Last Updated: 2026-08-24
