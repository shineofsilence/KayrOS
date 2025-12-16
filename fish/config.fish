
starship init fish | source
zoxide init fish | source

# ==================== Генерация цветов ====================
set -gx LS_COLORS (vivid generate snazzy)         # Генерация цветов для расширений

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

# =========== Горячие клавиши для редактирования ===========
function fish_user_key_bindings
    # Применяем бинды ко всем основным режимам (обычный и вставка)
    for mode in default insert
        bind -M $mode \ej backward-delete-char    # Backspace
        bind -M $mode \ek delete-char             # Delete
        bind -M $mode \eh backward-char           # Вправо на символ
        bind -M $mode \el forward-char            # Влево на символ
        bind -M $mode \cl forward-word            # Влево на слово
        bind -M $mode \f forward-word             # Влево на слово
    end
    bind -M insert \b backward-word               # Вправо на слово
    bind -M default \b backward-word              # Вправо на слово
end
