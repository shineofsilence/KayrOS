#!/usr/bin/env bash

handle() {
  if [[ ${1} == "openwindow"* ]]; then
    
    # 1. Разбираем аргументы события
    # Формат: openwindow>>ADDR,WORKSPACE_NAME,CLASS,TITLE
    data=${1#"openwindow>>"}
    IFS=',' read -r addr workspace_name class title <<< "$data"

    # 2. ФИЛЬТР: ЗАЩИТА ОВЕРЛЕЯ
    if [[ "$workspace_name" == "special:"* ]]; then
        return
    fi
    
    # 3. ПОЛУЧАЕМ ID ВОРКСПЕЙСА
    # Нам нужно найти ID того воркспейса, КУДА упало окно.
    # (Даже если мы сейчас смотрим в оверлей, окно упадет на background-воркспейс)
    workspace_id=$(hyprctl workspaces -j | jq -r ".[] | select(.name == \"$workspace_name\") | .id")

    # Если ID не найден (редкий баг инициализации), выходим
    if [[ -z "$workspace_id" ]]; then return; fi

    # 4. СЧИТАЕМ ОКНА
    # Считаем только тайловые (floating == false) окна на ЦЕЛЕВОМ воркспейсе.
    client_count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $workspace_id and .floating == false)] | length")

    # 5. ЛОГИКА
    # Если на столе стало ровно 2 окна...
    if [[ "$client_count" == "2" ]]; then
        # ...превращаем ИМЕННО ЭТО НОВОЕ окно (addr) в запертую группу.
        # Используем адрес из события, это надежнее, чем activewindow.
        hyprctl dispatch togglegroup "address:0x$addr"
        hyprctl dispatch lockactivegroup lock
    fi
  fi
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
