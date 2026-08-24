# luci-app-netbird

NetBird (0.77.1) для OpenWrt 25.x — собранный пакет `netbird` + заготовка под LuCI.

> Название историческое: сейчас репозиторий содержит пакет `netbird` (daemon+CLI).
> LuCI-интерфейс в планах; пока управление через SSH (`netbird status`, `/etc/init.d/netbird`).

## Установка

OpenWrt 25.x использует `apk`. Скачайте apk из [Releases](../../releases) и установите:

```sh
# скачать последнюю версию
URL=$(curl -s https://api.github.com/repos/nagual2/luci-app-netbird/releases/latest | grep -oE 'https://[^"]+x86_64\.apk' | head -1)
curl -L -o /tmp/netbird.apk "$URL"

# установить / обновить
apk add --allow-untrusted /tmp/netbird.apk
```

После установки:

```sh
/etc/init.d/netbird enable && /etc/init.d/netbird start
netbird up                 # регистрация (setup key или SSO)
netbird status
```

## Собрать самостоятельно

Пакет — это официальный `net/netbird` из [openwrt/packages](https://github.com/openwrt/packages)
с обновлённой версией ([PR #30370](https://github.com/openwrt/packages/pull/30370)):

- `net/netbird/Makefile` → PKG_VERSION 0.77.1, PKG_HASH пересчитан
- `files/netbird.init`, `test.sh` — без изменений от мантейнера

Сборка в SDK 25.12 x86_64:

```sh
./scripts/feeds update base packages && ./scripts/feeds install golang
cp -r net/netbird feeds/packages/net/netbird
make defconfig
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    make package/netbird/compile -j8
# результат: bin/packages/x86_64/packages/netbird-*.apk
```

(чистый PATH нужен в WSL — Windows-пути с `(x86)` ломают bash-рецепты)

## Статус PR

| Ветка openwrt/packages | было | стало |
|---|---|---|
| openwrt-25.12 ([PR #30370](https://github.com/openwrt/packages/pull/30370)) | 0.73.2 | **0.77.1** |

Мотивация: v0.76.0 закрывает локальную эскалацию привилегий
[GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr).

## Тестировалось

- Compile: OpenWrt SDK 25.12.0, x86/64
- Run: OpenWrt 25.12.4 x86_64 (Hyper-V VM), upgrade 0.66.2 → 0.77.1, procd service running
