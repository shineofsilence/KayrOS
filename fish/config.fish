source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
# === Функция y (Вход в Yazi с запоминанием папки) ===
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# === Автозапуск Yazi только в интерактивном режиме ===
if status is-interactive
    if test "$TERM" = "xterm-kitty"; and test -z "$YAZI_LEVEL"
        y
    end
end
