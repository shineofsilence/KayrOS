#!/usr/bin/env bash

# Получаем информацию о текущем окне
window=$(hyprctl activewindow -j)
is_grouped=$(echo "$window" | jq '.grouped')
# Координата X окна. Если > 500 (примерно), значит окно справа (Master).
# (Адаптируй под свое разрешение, если у тебя 4k, ставь 1000. Для 1920x1080 середина ~960)
# Но лучше проверять не координаты, а состояние.

if [[ "$is_grouped" == "true" ]]; then
    # === МЫ В СТОПКЕ (СЛЕВА) ===
    # 1. Вынимаем карту из колоды
    hyprctl dispatch moveoutofgroup
    # 2. Кидаем её на место Мастера (вправо)
    # (Hyprland сам поменяет их местами, так как там занято)
    hyprctl dispatch movewindow r
else
    # === МЫ В МАСТЕРЕ (СПРАВА) ===
    # 1. Кидаем окно влево (к стопке)
    hyprctl dispatch movewindow l
    # 2. Теперь мы соседи со стопкой. Всасываемся в неё.
    # Так как мы пришли справа, стопка слева.
    hyprctl dispatch moveintogroup l
    # На всякий случай (если лейаут перевернулся) пробуем остальные, это доли миллисекунды
    hyprctl dispatch moveintogroup r
    hyprctl dispatch moveintogroup u
    hyprctl dispatch moveintogroup d
fi
