-- ПРАВда там, где сердце. С какой стороны сердце? ПРАВильно: с ПРАВой.
-- Выбирайся из этого королевства кривых зеркал, дружок.

-- Единый список символов, из которых состоят слова.
local ALPHANUM_LIST = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя0123456789"

-- ================ Всмомогательные функции ================
-- ----------- Функция переназначения клавиш -----------
local function buf_map(mode, key, rhs)
    pcall(vim.keymap.del, mode, key, { buffer = 0 })
    vim.keymap.set(mode, key, rhs, { noremap = true, silent = true, nowait = true, buffer = 0 })
end

-- ------------- Строка визуально пустая? --------------
local function is_visually_empty(line)
    return line == "" or line:match("^%s*$")
end

-- --------- Функция перемещения по параграфам ---------
local function smart_paragraph(dir)
    local curr_pos = vim.api.nvim_win_get_cursor(0)
    local row = curr_pos[1]                             -- Текущая строка
    local total_lines = vim.api.nvim_buf_line_count(0)
    -- Получаем текущую строку для анализа состояния
    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    if #lines == 0 then return end
    -- Состояние: начинаем ли мы движение с "пустоты"?
    local on_empty = is_visually_empty(lines[1])
    local i = row + dir
    local found = false
    while i > 0 and i <= total_lines do
        local line_text = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        local line_empty = is_visually_empty(line_text)
        if on_empty then                          -- Мы стояли на пустой строке
            if not line_empty then
                on_empty = false 
            end
        else                                      -- Мы стояли на тексте
            if line_empty then
                row = i
                found = true
                break
            end
        end
        i = i + dir
    end
    -- Если не нашли параграф, прыгаем в самый конец/начало файла
    if not found then
        if dir == 1 then row = total_lines else row = 1 end
    end
    -- Ставим курсор в конец строки
    local target_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local col = #target_line
    if col > 0 then col = col - 1 end -- Коррекция для 0-based индексации
    vim.api.nvim_win_set_cursor(0, {row, col})
end

-- --------------- Получить тип символа ----------------
local function get_char_type(row, col)
    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    if #lines == 0 then return 0 end
    local line = lines[1]
    local char = vim.fn.matchstr(line, '.', col)
    if char == "" or char:match("%s") then return 0 end -- Пусто, пробел, не найдено - 0
    if ALPHANUM_LIST:find(char, 1, true) then           -- Есть в списке букв и цифр - 1
        return 1
    end
    return 0                                            -- По умолчанию - 0
end

-- ----------------- Шагание курсором ------------------
local function step_cursor(dir)
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1], pos[2]
    local line = vim.api.nvim_get_current_line()
    if dir == 1 then                                  -- ВПЕРЕД
        if col < #line then
            -- Узнаем ширину текущего символа
            local char = vim.fn.matchstr(line, '.', col)
            -- Шагаем ровно на ширину символа
            col = col + #char
            -- Если перешагнули конец строки - перенос строки
            if col >= #line then
                if row < vim.api.nvim_buf_line_count(0) then
                    row = row + 1; col = 0
                else
                    col = col - #char
                    return false                    -- Конец файла - false
                end
            end
        else
            if row < vim.api.nvim_buf_line_count(0) then
                row = row + 1; col = 0
            else return false end                   -- Конец строки - false
        end
    else                                              -- НАЗАД
        if col > 0 then
            -- Берем подстроку от начала до текущей позиции
            local substring = line:sub(1, col)
            -- Находим последний символ в этой подстроке
            local prev_char = vim.fn.matchstr(substring, '.$')
            -- Шагаем назад на его длину
            col = col - #prev_char
        else
            if row > 1 then
                row = row - 1
                -- Встаем корректно на начало последнего символа предыдущей строки
                local prev_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                if #prev_line > 0 then
                    local last_char = vim.fn.matchstr(prev_line, '.$')
                    col = #prev_line - #last_char
                else
                    col = 0
                end
            else return false end
        end
    end
    vim.api.nvim_win_set_cursor(0, {row, col})
    return true
end

-- --------------- Выделение символов вправо (w) ---------------
local function visual_char_w()
    local count = vim.v.count1                    -- Считываем цифру (по дефолту 1)
    vim.cmd("normal! v")                          -- Входим в режим выделения
    if count > 1 then
        for _ = 1, count - 1 do                   -- Шагаем count-1 раз (т.к. первый символ уже выделен)
            step_cursor(1)                        -- Шаг вперед
        end
    end
end

-- --------------- Выделение символов влево (W) ---------------
local function visual_char_W()
    local count = vim.v.count1                    -- Считываем цифру
    vim.cmd("normal! v")                          -- Входим в режим выделения
    if count > 1 then
        for _ = 1, count - 1 do                   -- Шагаем count-1 раз
            step_cursor(-1)                       -- Шаг назад
        end
    end
end

-- ------------ Под курсором начало слова? -------------
local function is_start(row, col)
    local curr = get_char_type(row, col)
    if curr == 0 then return false end            -- Если спецсимвол - 0
    if col == 0 then return true end              -- Если начало строки - 1
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local prev_char = vim.fn.matchstr(line:sub(1, col), '.$')
    local prev_type = 0
    if prev_char ~= "" and ALPHANUM_LIST:find(prev_char, 1, true) then
        prev_type = 1
    end
    return prev_type == 0                         -- Текущий - 1, предыдущий - 0
end

-- ------------- Под курсором конец слова? -------------
local function is_end(row, col)
    local curr = get_char_type(row, col)
    if curr == 0 then return false end            -- Разделитель не конец
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local curr_char_str = vim.fn.matchstr(line, '.', col)
    local next_col = col + #curr_char_str
    local next_type = get_char_type(row, next_col)
    return next_type == 0                         -- Текущий - 1, следующий - 0
end

-- ------ В начало последнего (предыдущего) слова ------
local function move_prev_start()
    local p = vim.api.nvim_win_get_cursor(0)
    if is_start(p[1], p[2]) then                  -- Если мы в начале слова
        step_cursor(-1)                             -- Шаг назад
    end
    -- Бежим назад, пока не найдем начало
    for _ = 1, 1000 do                            -- Лимит шагов от зависания
        local pos = vim.api.nvim_win_get_cursor(0)
        if is_start(pos[1], pos[2]) then return end
        if not step_cursor(-1) then return end
    end
end

-- ------------- В конец предыдущего слова -------------
local function move_prev_end()
    step_cursor(-1)                               -- Сходим с текущей позиции
    for _ = 1, 1000 do
        local pos = vim.api.nvim_win_get_cursor(0)
        if is_end(pos[1], pos[2]) then return end
        if not step_cursor(-1) then return end
    end
end

-- ------------- В начало следующего слова -------------
local function move_next_start()
    step_cursor(1)                                -- Сходим с текущей позиции
    for _ = 1, 1000 do
        local pos = vim.api.nvim_win_get_cursor(0)
        if is_start(pos[1], pos[2]) then return end
        if not step_cursor(1) then return end
    end
end

-- ------ В конец текущего (следующего) слова ------
local function move_next_end()
    local p = vim.api.nvim_win_get_cursor(0)
    if is_end(p[1], p[2]) then                    -- Если мы в конце слова
        step_cursor(1)                              -- Шаг вперед
    end
    for _ = 1, 1000 do
        local pos = vim.api.nvim_win_get_cursor(0)
        if is_end(pos[1], pos[2]) then return end
        if not step_cursor(1) then return end
    end
end

-- --------------- Выделение слов вправо ---------------
local function visual_subword_e()
    local count = vim.v.count1                    -- Количество слов для выделения
    local p = vim.api.nvim_win_get_cursor(0)
    local c_type = get_char_type(p[1], p[2])      -- Тип символа под курсором
    if c_type == 0 then                           -- Если над спецсимволом
        move_next_start()                           -- В начало следующего слова
    else                                          -- Если стоим на слове
        if not is_start(p[1], p[2]) then            -- Если мы не в его начале
            move_prev_start()                         -- Встаём на это начало
        end
    end
    vim.cmd("normal! v")                          -- Включаем режим выделения
    -- Проверка на односимвольное слово
    local curr_p = vim.api.nvim_win_get_cursor(0)
    if is_end(curr_p[1], curr_p[2]) then          -- Если начало и конец совпадают
        count = count - 1                           -- Уменьшаем счётчик на один
    end
    for _ = 1, count do                           -- Выделяем нужное количество слов
        move_next_end()
    end
end

-- --------------- Выделение слов влево ---------------
local function visual_subword_E()
    local count = vim.v.count1                    -- Количество слов для выделения
    local p = vim.api.nvim_win_get_cursor(0)
    local c_type = get_char_type(p[1], p[2])      -- Тип символа под курсором
    if c_type == 0 then                           -- Если над спецсимволом
        move_prev_end()                             -- В конец предыдущего слова
    else                                          -- Если стоим на слове
        if not is_end(p[1], p[2]) then              -- Если мы не в его конце
            move_next_end()                           -- Встаём на его конец
        end
    end
    vim.cmd("normal! v")                          -- Включаем режим выделения
    -- Проверка на односимвольное слово
    local curr_p = vim.api.nvim_win_get_cursor(0)
    if is_start(curr_p[1], curr_p[2]) then        -- Если начало и конец совпадают
        count = count - 1                           -- Уменьшаем счётчик на 1
    end
    for _ = 1, count do                           -- Выделяем нужное количество слов
        move_prev_start()
    end
end

-- ==================== Горячие клавиши ====================
local function apply_binds()
    -- Если текущий буфер — это спец-окно, мы НЕ применяем наши бинды,
    local ignore_filetypes = {
        "neo-tree",
        "neo-tree-popup",   -- !!! ДОБАВИТЬ ЭТУ СТРОКУ !!!
        "TelescopePrompt",
        "lazy",
        "mason",
        "toggleterm",
        "dashboard",
        "checkhealth"
    }
    if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
        return
    end

    -- ------------------ Движение вправо ------------------
    buf_map({'n', 'v'}, 'h', 'h')
    -- ... (дальше твой обычный код) ...
    -- ------------------ Движение вправо ------------------
    buf_map({'n', 'v'}, 'h', 'h')                     -- Вправо на символ
    buf_map({'n', 'v'}, 'р', 'h')                     -- Вправо на символ
    buf_map({'n', 'v'}, 'H', '^')                     -- В начало строки (первый символ)
    buf_map({'n', 'v'}, 'Р', '^')                     -- В начало строки (первый символ)
    buf_map({'n', 'v'}, 'y', move_prev_start)         -- Вправо по началам слов
    buf_map({'n', 'v'}, 'н', move_prev_start)         -- Вправо по началам слов
    buf_map({'n', 'v'}, 'Y', move_prev_end)           -- Вправо по концам слов
    buf_map({'n', 'v'}, 'Н', move_prev_end)           -- Вправо по концам слов

    -- ------------------ Движение влево -------------------
    buf_map({'n', 'v'}, 'l', 'l')                     -- Влево на символ
    buf_map({'n', 'v'}, 'д', 'l')                     -- Влево на символ
    buf_map({'n', 'v'}, 'L', '$')                     -- В конец строки
    buf_map({'n', 'v'}, 'Д', '$')                     -- В конец строки
    buf_map({'n', 'v'}, 'o', move_next_start)         -- Влево по началам слов
    buf_map({'n', 'v'}, 'щ', move_next_start)         -- Влево по началам слов
    buf_map({'n', 'v'}, 'O', move_next_end)           -- Влево по концам слов
    buf_map({'n', 'v'}, 'Щ', move_next_end)           -- Влево по концам слов

    -- ------------------ Движение вверх -------------------
    buf_map({'n', 'v'}, 'k', 'k')                     -- Вверх на строку
    buf_map({'n', 'v'}, 'л', 'k')                     -- Вверх на стреку
    buf_map({'n', 'v'}, 'K', '4k')                    -- Вверх на 4 строки
    buf_map({'n', 'v'}, 'Л', '4k')                    -- Вверх на 4 строки
    buf_map({'n', 'v'}, 'i', function() smart_paragraph(-1) end) -- Вверх на параграф
    buf_map({'n', 'v'}, 'ш', function() smart_paragraph(-1) end) -- Вверх на параграф
    buf_map({'n', 'v'}, 'I', 'gg')                    -- Вверх в начало файла
    buf_map({'n', 'v'}, 'Ш', 'gg')                    -- Вверх в начало файла

    -- ------------------- Движение вниз -------------------
    buf_map({'n', 'v'}, 'j', 'j')                     -- Вниз на строку
    buf_map({'n', 'v'}, 'о', 'j')                     -- Вниз на строку
    buf_map({'n', 'v'}, 'J', '4j')                    -- Вниз на 4 строки
    buf_map({'n', 'v'}, 'О', '4j')                    -- Вниз на 4 строки
    buf_map({'n', 'v'}, 'u', function() smart_paragraph(1) end) -- Вниз на параграф
    buf_map({'n', 'v'}, 'г', function() smart_paragraph(1) end) -- Вниз на параграф
    buf_map({'n', 'v'}, 'U', 'G')                     -- Вниз в конец файла
    buf_map({'n', 'v'}, 'Г', 'G')                     -- Вниз в конец файла

    -- ------------ Перемещение по спецсимволам ------------
    local jump_chars = {
        "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", -- Числовой ряд + Shift
        "-", "_", "=", "+",                               -- Минус, Плюс и их Шифты
        "\\", "|",                                        -- Обратный слеш и Пайп
        "[", "]", "{", "}",                               -- Скобки
        "'", '"', "`", "~",                               -- Кавычки и Тильда
        ",", ".", ";"                                     -- Пунктуация
    }
    for _, char in ipairs(jump_chars) do
        local pattern = char
        if char == "\\" then pattern = "\\\\" end         -- Экранирование обратного слэша
        buf_map('n', char, '/\\V' .. pattern .. '<CR>')   -- Переназначение клавиши
    end

    -- ================ Вход в режим выделения =================
    buf_map('n', 'w', visual_char_w)                  -- Выделение символов влево
    buf_map('n', 'ц', visual_char_w)                  -- Выделение символов влево
    buf_map('n', 'W', visual_char_W)                  -- Выделение символов вправо
    buf_map('n', 'Ц', visual_char_W)                  -- Выделение символов вправо
    buf_map('n', 'e', visual_subword_e)               -- Выделение слов влево
    buf_map('n', 'у', visual_subword_e)               -- Выделение слов влево
    buf_map('n', 'E', visual_subword_E)               -- Выделение слов вправо
    buf_map('n', 'У', visual_subword_E)               -- Выделение слов вправо
    buf_map('n', 'r', 'V')                            -- Выделение строк ниже
    buf_map('n', 'к', 'V')                            -- Выделение строк ниже
    buf_map('n', 'R', 'V')                            -- Выделение строк выше
    buf_map('n', 'К', 'V')                            -- Выделение строк выше

    -- ------- Выделение внутри парных спецсимволов --------
    local symbols = { "'", '"', "(", ")", "[", "]", "{", "}" }
    for _, sym in ipairs(symbols) do
        local text_obj = sym
        if sym == "{" or sym == "}" then text_obj = "B" end
        buf_map('n', 'f' .. sym, 'vi' .. text_obj)
        buf_map('n', 'а' .. sym, 'vi' .. text_obj)
        buf_map('n', 'F' .. sym, 'vi' .. text_obj)
        buf_map('n', 'А' .. sym, 'vi' .. text_obj)
    end
end

-- -------- Применение биндов при входе в буфер --------
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("KayMovement", { clear = true }),
    pattern = "*",
    callback = apply_binds
})
apply_binds()                            -- Применяем один раз сразу

