function lf --wraps=lf --description "Файловый менеджер меняет папку консоли при выходе"
    # Создаем временный файл для хранения пути
    set -l tmp (mktemp)

    # Запускаем LF, передавая ему флаг для записи пути при выходе
    command lf -last-dir-path=$tmp $argv

    # После закрытия LF проверяем, существует ли файл
    if test -f "$tmp"
        set -l dir (cat $tmp)
        rm -f $tmp
        
        # Если там записана валидная папка и она отличается от текущей - переходим
        if test -d "$dir"
            if test "$dir" != (pwd)
                cd "$dir"
            end
        end
    end
end
