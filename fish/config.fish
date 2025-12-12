
starship init fish | source
zoxide init fish | source
# ==================== Генерация цветов ====================
# vivid генерирует LS_COLORS для сотен расширений (включая gleam, rust и т.д.)
# Можно выбрать тему: molokai, onedark, dracula, и т.д.
set -gx LS_COLORS (vivid generate snazzy)
# ==================== Yazi Wrapper ====================
function y
    # 1. Создаем временный файл, куда yazi запишет путь при выходе
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    
    # 2. Запускаем yazi, передавая ему этот файл
    # $argv позволяет передавать аргументы, например 'y /etc'
    yazi $argv --cwd-file="$tmp"
    
    # 3. После выхода проверяем файл
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        # Если путь изменился — переходим туда
        builtin cd -- "$cwd"
    end
    
    # 4. Удаляем мусор
    rm -f -- "$tmp"
end
