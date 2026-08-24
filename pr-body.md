## 📦 Package Details

**Maintainer:** @wehagy 
**Description:**

Update netbird to upstream v0.77.1.

Changelog: https://github.com/netbirdio/netbird/compare/v0.73.2...v0.77.1

Notable changes:
- fix local privilege escalation via unauthenticated daemon IPC socket ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)), affects all client versions < 0.76.0
- fix nftables route rule expression ordering
- fall back to per-IP ACL rules when ipset is unavailable

---

## 🧪 Run Testing Details

- **OpenWrt Version:** 25.12.4
- **OpenWrt Target/Subtarget:** x86/64
- **OpenWrt Device:** Hyper-V VM

Compile tested: OpenWrt SDK 25.12.0, x86_64 (`make package/netbird/compile` → `netbird-0.77.1-r1.apk`)
Run tested: upgraded installed package on 25.12.4 x86_64, procd service starts, `netbird version` reports 0.77.1, CLI status works against running daemon.

---

## ✅ Formalities

- [x] I have reviewed the [CONTRIBUTING.md](https://github.com/openwrt/packages/blob/master/CONTRIBUTING.md) file for detailed contributing guidelines.
