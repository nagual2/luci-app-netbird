# netbird 0.77.1 — update package for openwrt/packages

Рабочая копия пакета `net/netbird` из [openwrt/packages](https://github.com/openwrt/packages) (ветка openwrt-25.12)
с обновлением до upstream [v0.77.1](https://github.com/netbirdio/netbird/releases/tag/v0.77.1).

Готово к отправке PR в официальный репозиторий.

## Что изменено (diff против openwrt-25.12)

- `net/netbird/Makefile`: `PKG_VERSION` 0.73.2 → 0.77.1, `PKG_HASH` пересчитан
- Остальные файлы (`files/netbird.init`, `test.sh`) — без изменений: env-переменные
  (`NB_STATE_DIR`, `NB_DNS_STATE_FILE`, `NB_DISABLE_SSH_CONFIG`, ...) и команда запуска
  `netbird service run` совместимы с 0.77.1

## Тестирование

### SDK-сборка (compile tested)

```sh
# OpenWrt SDK 25.12.0, x86_64, gcc-14.3.0 musl
./scripts/feeds update base packages
./scripts/feeds install golang
cp -r net/netbird feeds/packages/net/netbird
make defconfig
make package/netbird/compile -j8
# → bin/packages/x86_64/packages/netbird-0.77.1-r1.apk (15 MB)
```

Примечание: в WSL с Windows-PATH сборка падает на `syntax error near unexpected token '('`
(пути `Program Files (x86)` из интеропа ломают inline `PATH=` в рецептах).
Лечение: запускать make с чистым PATH:

```sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make package/netbird/compile -j8
```

### Runtime (run tested)

OpenWrt 25.12.4 x86_64 VM (openwrt-dev):

```
apk add --allow-untrusted /tmp/netbird-0.77.1-r1.apk
# Upgrading netbird (0.66.2-r1 -> 0.77.1-r1) — ок
/etc/init.d/netbird start   # → running (procd)
netbird status --json       # cliVersion 0.77.1, daemonVersion 0.77.1
```

## Как отправить PR

```sh
git clone git@github.com:<you>/packages.git && cd packages
git checkout -b netbird-0.77.1 origin/openwrt-25.12   # или master
cp -r ../luci-app-netbird/net/netbird net/
git add net/netbird && git commit -s
git push -u origin netbird-0.77.1
# PR в openwrt/packages, ветка openwrt-25.12 и/или master,
# maintainer: @wehagy (Wesley Gimenes)
```

Шаблон коммит-сообщения — как у [PR #29863](https://github.com/openwrt/packages/pull/29863):

```
netbird: update to 0.77.1

Maintainer: Wesley Gimenes <wehagy@proton.me> @wehagy
Changelog: https://github.com/netbirdio/netbird/compare/v0.73.2...v0.77.1

Compile tested: x86_64, OpenWrt 25.12.0 SDK
Run tested: x86_64, OpenWrt 25.12.4

Signed-off-by: <Name> <email>
```

Мотивация для PR: v0.76.0 закрывает локальную эскалацию привилегий
[GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr),
затронуты все версии < 0.76.0.
