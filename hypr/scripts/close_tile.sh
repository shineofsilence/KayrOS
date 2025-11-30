#!/usr/bin/env bash

# Получаем информацию об активном окне
ACTIVE_WORKSPACE=$(hyprctl activewindow -j | jq -r ".workspace.name")

if [[ "$ACTIVE_WORKSPACE" == "special:overlay" ]]; then
    # Если мы в оверлее:
    # 1. Убиваем окно
    hyprctl dispatch killactive
    # 2. Сворачиваем шторку (чтобы не оставалось серого экрана)
    hyprctl dispatch togglespecialworkspace overlay
else
    # Если мы в обычном режиме:
    # Просто убиваем окно
    hyprctl dispatch killactive
fi
