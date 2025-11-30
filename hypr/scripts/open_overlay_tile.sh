#!/usr/bin/env bash
# $1 = команда запуска (например "kitty --class htop htop")

WORKSPACE="special:overlay"

# 1. ОБЕСПЕЧИВАЕМ ВИДИМОСТЬ
# Если оверлей закрыт — открываем его.
# Теперь он не закроется сам, даже если будет пустым (благодаря настройке в misc).
if ! hyprctl monitors -j | jq -r '.[].specialWorkspace.name' | grep -q "$WORKSPACE"; then
    hyprctl dispatch togglespecialworkspace overlay
fi

# 2. УБИВАЕМ ВСЁ СТАРОЕ
# Находим адреса окон в оверлее и убиваем их.
PIDS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$WORKSPACE\") | .address")
for addr in $PIDS; do
    hyprctl dispatch closewindow "address:$addr"
done

# 3. ЗАПУСКАЕМ НОВОЕ
# Принудительно в оверлей (на всякий случай дублируем логику правил)
hyprctl dispatch exec "[workspace $WORKSPACE] $1"
