if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# === YAZI CONFIGURATION (Только для хоста) ===
# Проверяем: (1) Мы НЕ в Distrobox, (2) Yazi установлен в системе
if test -z "$DISTROBOX_ENTER"; and command -q yazi
    # Функция-обертка для выхода в текущую папку
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
    # Автозапуск только в Kitty и интерактивном режиме
    if status is-interactive; and test "$TERM" = "xterm-kitty"; and test -z "$YAZI_LEVEL"
        y
    end
end
starship init fish | source
