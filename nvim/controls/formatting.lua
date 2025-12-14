-- ----------- Функция переназначения клавиш -----------
local function soft_map(mode, key, rhs)
    vim.keymap.set(mode, key, rhs, { noremap = true, silent = true, nowait = true, buffer = 0 })
end

-- ---- Функция переназначения клавиш с затиранием -----
local function hard_map(mode, key, rhs)
    pcall(vim.keymap.del, mode, key, { buffer = 0 })
    vim.keymap.set(mode, key, rhs, { noremap = true, silent = true, nowait = true, buffer = 0 })
end

-- --------------- Вставка пустых строк ----------------
local function newline(direction)
    -- Получаем текущую строку и курсор
    local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^(%s*)") or ""                 -- Получаем отступ
    local start_row = (direction == 'below') and r or r - 1   -- Определяем позицию вставки
    vim.api.nvim_buf_set_lines(0, start_row, start_row, false, {indent}) -- Вставляем строку с отступом
    local new_row = (direction == 'below') and r + 1 or r     -- Перемещаем курсор на новую строку в конец отступа
    vim.api.nvim_win_set_cursor(0, {new_row, #indent})
end

-- --------- Оформление разделов и подразделов ---------
local function create_section_comment(is_large)
    local line = vim.api.nvim_get_current_line()
    -- Получаем символ комментария
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end
    local comment_char = vim.trim(vim.split(cms, "%s")[1])
    -- Настройки оформления
    local target_width = is_large and 60 or 56
    local deco_char = is_large and "=" or "-"
    -- Ищем строку, которая является разделом
    local esc_cc = comment_char:gsub("([^%w])", "%%%1")
    local any_section_pattern = "^%s*" .. esc_cc .. "%s*[%-=]+"
    -- Валидация: если строка не пуста и это не раздел
    if not line:match("^%s*$") and not line:match(any_section_pattern) then
        return                                    -- Выход
    end
    local indent = line:match("^(%s*)") or ""
    -- Ввод названия
    local title = vim.fn.input(is_large and "Section: " or "Subsection: ")
    if title == "" then return end
    -- Расчет визуальной ширины
    local title_width = vim.fn.strdisplaywidth(title)
    local comm_width = vim.fn.strdisplaywidth(comment_char)
    -- Рассчитываем количество символов оформления
    local overhead = comm_width + 3 
    local available = target_width - title_width - overhead
    if available < 2 then available = 2 end
    local left_len = math.floor(available / 2)
    local right_len = available - left_len
    -- Сборка строки
    local new_line = string.format(
        "%s%s %s %s %s",
        indent,
        comment_char,
        string.rep(deco_char, left_len),
        title,
        string.rep(deco_char, right_len)
    )
    vim.api.nvim_set_current_line(new_line)
end

-- ---------- Определение символа комментария ----------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",                  -- Все типы файлов
    callback = function()
        if vim.bo.commentstring == "" then        -- Если переменная пуста
            vim.bo.commentstring = "# %s"           -- Символ #
        end
    end,
})

-- ---------- Создание комментария на отступе ----------
local function aligned_comment()
    -- -------------------- Подготовка данных --------------------
    local line = vim.api.nvim_get_current_line()
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end           -- Значение по умолчанию
    local comment_char = vim.trim(vim.split(cms, "%s")[1])  -- Символ комментария
    -- Ищем комментарий с конца строки (реверс)
    local rev_line = line:reverse()
    local rev_char = comment_char:reverse()
    local s_rev_start, s_rev_end = rev_line:find(rev_char, 1, true)
    -- -------------- Если комментарий найден --------------
    if s_rev_start then
        local s_start = #line - s_rev_end + 1             -- Вычисляем реальный индекс
        local content_before = line:sub(1, s_start - 1)   -- Текст до комментария
        -- 1а. Если до комментария пусто - ничего не делаем
        if content_before:match("^%s*$") then             -- Если до комментария пусто
            return                                          -- Выходим
        end
        -- Если код есть - удаляем комментарий
        local clean_code = content_before:match("^(.*%S)") or ""
        vim.api.nvim_set_current_line(clean_code)
    -- ------------ Если комментарий не найден -------------
    else
        local clean_line = line:match("^(.*%S)") or "" -- Очищаем хвост строки
        -- Считаем отступы до 50 колонки
        local line_width = vim.fn.strdisplaywidth(clean_line)
        local spaces_count = math.max(1, 50 - line_width)
        -- Формируем строку
        local new_line = clean_line .. string.rep(" ", spaces_count) .. comment_char .. " "
        vim.api.nvim_set_current_line(new_line)
        -- Ставим курсор в конец и переходим в режим редактирования
        vim.api.nvim_win_set_cursor(0, {vim.fn.line('.'), #new_line})
        vim.cmd("startinsert!")
    end
end

-- ----------- Сдвиг комментария на отступе ------------
local function move_comment(dir)
    local line = vim.api.nvim_get_current_line()
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end
    local comment_char = vim.trim(vim.split(cms, "%s")[1])
    -- Ищем комментарий
    local rev_line = line:reverse()
    local rev_char = comment_char:reverse()
    local s_rev_start, s_rev_end = rev_line:find(rev_char, 1, true)
    if not s_rev_start then return end            -- Комментария нет, выходим
    -- Разделяем код и комментарий
    local s_start = #line - s_rev_end + 1
    local content_before = line:sub(1, s_start - 1)
    -- Если строка-комментарий, не двигаем
    if content_before:match("^%s*$") then return end
    local clean_code = content_before:match("^(.*%S)") or ""
    local comment_part = line:sub(s_start)
    -- Считаем позиции
    local code_width = vim.fn.strdisplaywidth(clean_code)
    local current_col = vim.fn.strdisplaywidth(content_before) + 1
    local target_col = current_col + (dir * 2)    -- Вычисляем цель
    -- Выравнивание по нечётной сетке
    if target_col % 2 == 0 then
        target_col = target_col + 1               -- Всегда сдвигаем на +1 для нечётности
    end
    -- Граничное условие (минимум 1 пробел)
    local min_col = code_width + 2                -- Код + 1 пробел + 1 (начало коммента)
    if target_col < min_col then
        target_col = min_col                      -- Тут сетка может нарушиться ради 1 пробела
    end
    -- Если позиция не изменилась (уперлись), ничего не обновляем
    if target_col == current_col then return end
    -- Сборка строки
    local spaces_count = target_col - code_width - 1
    local new_line = clean_code .. string.rep(" ", spaces_count) .. comment_part
    vim.api.nvim_set_current_line(new_line)
    -- Двигаем курсор вместе с текстом, если он был на строке
    local cur = vim.api.nvim_win_get_cursor(0)
    if cur[2] >= #clean_code then
        vim.api.nvim_win_set_cursor(0, {cur[1], cur[2] + (target_col - current_col)})
    end
end

-- ----------- Принудительный сдвиг отступа ------------
local function force_indent(dir)
    -- dir: 1 (вправо/tab), -1 (влево/untab)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    -- Получаем текущий отступ
    local current_indent = vim.fn.indent(row)
    local shiftwidth = vim.fn.shiftwidth()
    -- Рассчитываем новый отступ
    local new_indent_len = current_indent + (dir * shiftwidth)
    if new_indent_len < 0 then new_indent_len = 0 end
    -- Создаем новую строку отступов
    local indent_char = vim.bo.expandtab and " " or "\t"
    local new_indent_str = ""
    if vim.bo.expandtab then
        new_indent_str = string.rep(" ", new_indent_len)
    else
        -- Для табов логика чуть сложнее, но обычно просто N табов
        local tabs = math.floor(new_indent_len / shiftwidth)
        new_indent_str = string.rep("\t", tabs)
    end
    -- Если строка пустая - просто вставляем отступ
    if line:match("^%s*$") then
        vim.api.nvim_set_current_line(new_indent_str)
    else
        -- Если не пустая - заменяем старый отступ на новый
        local content = line:match("^%s*(.*)")
        vim.api.nvim_set_current_line(new_indent_str .. content)
    end
end

-- -------- Комментирование в режиме выделения ---------
local function toggle_visual_comment()
    -- Получаем границы выделения
    local l_start = vim.fn.line("v")
    local l_end = vim.fn.line(".")
    if l_start > l_end then l_start, l_end = l_end, l_start end
    -- Читаем строки
    local lines = vim.api.nvim_buf_get_lines(0, l_start - 1, l_end, false)
    -- Определяем символ комментария
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end
    local comment_char = vim.trim(vim.split(cms, "%s")[1])
    -- Экранируем спецсимволы для Lua паттернов (например, -, *, +)
    local esc_char = comment_char:gsub("([^%w])", "%%%1")
    -- Анализ состояния: Все ли строки закомментированы?
    local all_commented = true
    for _, line in ipairs(lines) do
        -- Игнорируем пустые строки при проверке
        if not line:match("^%s*$") then
            -- Проверяем: Начало строки + Пробелы + Символ комментария
            if not line:match("^%s*" .. esc_char) then
                all_commented = false
                break
            end
        end
    end
    -- Обработка строк
    local new_lines = {}
    for _, line in ipairs(lines) do
        if line:match("^%s*$") then
            table.insert(new_lines, line) -- Пустые не трогаем
        else
            if all_commented then
                -- Раскомментировать
                local indent, content = line:match("^(%s*)" .. esc_char .. "%s?(.*)")
                table.insert(new_lines, indent .. (content or ""))
            else
                -- Закомментировать
                local indent, content = line:match("^(%s*)(.*)")
                table.insert(new_lines, indent .. comment_char .. " " .. content)
            end
        end
    end
    -- Применяем изменения и выходим в Normal mode
    vim.api.nvim_buf_set_lines(0, l_start - 1, l_end, false, new_lines)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

-- ==================== Горячие клавиши ====================
local function apply_formatting_binds()
    -- --------------- Вставка пустых строк ----------------
    hard_map('n', 'g', function() newline('below') end)             -- Пустая строка после
    hard_map('n', 'п', function() newline('below') end)             -- Пустая строка после
    hard_map('n', 'G', function() newline('above') end)             -- Пустая строка до
    hard_map('n', 'П', function() newline('above') end)             -- Пустая строка до

    -- --------------- Разделы и подразделы ----------------
    soft_map('n', 'x', function() create_section_comment(false) end) -- Малый (-)
    soft_map('n', 'ч', function() create_section_comment(false) end) -- Малый (-)
    soft_map('n', 'X', function() create_section_comment(true) end) -- Большой (=)
    soft_map('n', 'Ч', function() create_section_comment(true) end) -- Большой (=)

    -- -------------------- Комментарии --------------------
    soft_map('n', 'z', function() require('Comment.api').toggle.linewise.current() end) -- Комментирование строки
    soft_map('n', 'я', function() require('Comment.api').toggle.linewise.current() end) -- Комментирование строки
    soft_map('n', 'Z', aligned_comment)                             -- Комментарий на отступе
    soft_map('n', 'Я', aligned_comment)                             -- Комментарий на отступе
    soft_map('v', 'z', toggle_visual_comment)                       -- Комментирование блоков кода
    soft_map('v', 'я', toggle_visual_comment)                       -- Комментирование блоков кода

    -- ---------------------- Сдвиги -----------------------
    hard_map('n', '<', function() force_indent(-1) end)             -- Сдвиг вправо
    hard_map('n', 'Б', function() force_indent(-1) end)             -- Сдвиг вправо
    hard_map('n', '>', function() force_indent(1) end)              -- Сдвиг влево
    hard_map('n', 'Ю', function() force_indent(1) end)              -- Сдвиг влево
    soft_map('v', '<', '<gv')                                       -- Сдвиг блока вправо
    soft_map('v', 'Б', '<gv')                                       -- Сдвиг блока вправо
    soft_map('v', '>', '>gv')                                       -- Сдвиг блока влево
    soft_map('v', 'Ю', '>gv')                                       -- Сдвиг блока влево
    soft_map({'n', 'i'}, '<M-,>', function() move_comment(-1) end)  -- Сдвиг комментария вправо
    soft_map({'n', 'i'}, '<M-б>', function() move_comment(-1) end)  -- Сдвиг комментария вправо
    soft_map({'n', 'i'}, '<M-.>', function() move_comment(1) end)   -- Сдвиг комментария влево
    soft_map({'n', 'i'}, '<M-ю>', function() move_comment(1) end)   -- Сдвиг комментария влево
end

-- -------- Применение биндов при входе в буфер --------
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("KayFormatting", { clear = true }),
    pattern = "*",
    callback = apply_formatting_binds
})
apply_formatting_binds()                            -- Применяем один раз сразу

