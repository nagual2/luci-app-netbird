# netbird 0.77.1 для OpenWrt 25.x

[English](README.md) | **Русский** | [Deutsch](README.de.md)

Автономный пакет OpenWrt, выделенный из [openwrt/packages `net/netbird`](https://github.com/openwrt/packages/tree/master/net/netbird) с обновлением версии до апстримной **[v0.77.1](https://github.com/netbirdio/netbird/releases/tag/v0.77.1)**.

Готовые `apk`-пакеты — в разделе [Releases](../../releases).

## Зачем обновляться

В v0.76.0 закрыта **локальная эскалация привилегий** в демоне ([GHSA-qcpp-8vwj-hhwr](https://github.com/netbirdio/netbird/security/advisories/GHSA-qcpp-8vwj-hhwr)): мир-writable IPC-сокет принимал любого вызывающего без аутентификации — любой локальный пользователь мог получить root через функцию SSH-сервера. Уязвимы все версии < 0.76.0.

Также: фикс порядка выражений в nftables route rules, fallback на per-IP ACL при недоступном `ipset`.

## Установка (OpenWrt 25.x / apk)

```sh
# скачать последний релиз под свою архитектуру
URL=$(curl -s https://api.github.com/repos/nagual2/luci-app-netbird/releases/latest \
  | grep -oE 'https://[^"]+x86_64\.apk' | head -1)
curl -L -o /tmp/netbird.apk "$URL"

# установка или обновление (конфиг сохраняется)
apk add --allow-untrusted /tmp/netbird.apk
rm -f /tmp/netbird.apk

/etc/init.d/netbird enable && /etc/init.d/netbird start
netbird up        # регистрация: setup key или SSO
netbird status
```

Либо с рабочей машины по SSH:

```sh
./scripts/install-apk.sh <router-host> x86_64              # x86_64
./scripts/install-apk.sh <router-host> aarch64_cortex-a53  # mediatek/filogic (напр. Xiaomi AX3000T)
```

Поддерживаемые архитектуры: **x86_64**, **aarch64_cortex-a53** (mediatek/filogic). Апгрейд поверх стокового пакета 25.12 работает; procd init-скрипт и конфиги в `/etc/config` сохраняются.

## Сборка из исходников

Нужен Linux (или WSL2). SDK скачивается автоматически:

```sh
./scripts/build-apk-sdk.sh                    # x86_64
SDK_URL=https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/openwrt-sdk-25.12.5-mediatek-filogic_gcc-14.3.0_musl.Linux-x86_64.tar.zst \
  ./scripts/build-apk-sdk.sh                  # aarch64_cortex-a53
```

Результат в `dist/`. Замечание для WSL: make нужно запускать с чистым PATH — Windows-пути вида `Program Files (x86)` ломают рецепты OpenWrt (`syntax error near unexpected token '('`). Скрипт сборки это уже учитывает.

CI собирает обе архитектуры на каждый push в `main`; push тега (`v*`) прикрепляет пакеты к GitHub Release.

## Синхронизация с апстримом

Дерево пакета зеркалирует `net/netbird` из ветки `openwrt-25.12`:

```sh
./scripts/sync-from-upstream.sh
```

Состояние синка и открытый PR — в [UPSTREAM.md](UPSTREAM.md).

| Ветка | Стоковая версия | Этот репо |
|---|---|---|
| openwrt-25.12 | 0.73.2 | **0.77.1-1** |

## Тестирование

| Этап | Окружение |
|---|---|
| Сборка | OpenWrt SDK 25.12.5, x86_64 + mediatek/filogic (aarch64_cortex-a53) |
| Запуск | OpenWrt 25.12.4 x86_64 VM: апгрейд 0.66.2 → 0.77.1, сервис procd running, CLI/daemon 0.77.1 |

## Лицензия

BSD-3-Clause (netbird), GPL-2.0 (упаковка OpenWrt) — см. [NOTICE](NOTICE).
