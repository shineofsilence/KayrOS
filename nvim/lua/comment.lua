local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ======== Функция создания комментария на отступе ========
local function aligned_comment()
    -- -------------------- Подготовка данных --------------------
    local line = vim.api.nvim_get_current_line()
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end         -- Значение по умолчанию
    -- Получаем сам символ комментария (до %s)
    local comment_char = vim.trim(vim.split(cms, "%s")[1])

    -- 0. Ищем комментарий с конца строки (реверс)
    local rev_line = line:reverse()
    local rev_char = comment_char:reverse()
    local s_rev_start, s_rev_end = rev_line:find(rev_char, 1, true)

    -- -------------- Если комментарий найден --------------
    if s_rev_start then
        local s_start = #line - s_rev_end + 1             -- Вычисляем реальный индекс
        local content_before = line:sub(1, s_start - 1)   -- Текст до комментария
        -- 1а. Если до комментария пусто - ничего не делаем
        if content_before:match("^%s*$") then
            return
        end
        -- 1б. Если код есть - удаляем комментарий
        local clean_code = content_before:match("^(.*%S)") or ""
        vim.api.nvim_set_current_line(clean_code)

    -- ------------ Если комментарий не найден -------------
    else
        -- 2а. Очищаем хвост строки
        local clean_line = line:match("^(.*%S)") or ""
        -- 2б. Считаем отступы до 50 колонки
        local line_width = vim.fn.strdisplaywidth(clean_line)
        local spaces_count = math.max(1, 50 - line_width)
        -- Формируем строку
        local new_line = clean_line .. string.rep(" ", spaces_count) .. comment_char .. " "
        vim.api.nvim_set_current_line(new_line)
        -- Ставим курсор в конец и переходим в Insert
        vim.api.nvim_win_set_cursor(0, {vim.fn.line('.'), #new_line})
        vim.cmd("startinsert!")
    end
end
-- Добавляем описание к опциям для which-key (если используется)
local key_opts = vim.tbl_extend("force", opts, { desc = "Aligned Comment" })

-- ======== Функции сдвига комментариев на отступе =========
local function move_comment(dir)
    local line = vim.api.nvim_get_current_line()
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end
    local comment_char = vim.trim(vim.split(cms, "%s")[1])

    -- 0. Ищем комментарий (как в aligned_comment)
    local rev_line = line:reverse()
    local rev_char = comment_char:reverse()
    local s_rev_start, s_rev_end = rev_line:find(rev_char, 1, true)
    if not s_rev_start then return end -- Комментария нет, выходим

    -- 1. Разделяем код и комментарий
    local s_start = #line - s_rev_end + 1
    local content_before = line:sub(1, s_start - 1)
    -- Если "код" пустой (строка-комментарий), не двигаем
    if content_before:match("^%s*$") then return end
    local clean_code = content_before:match("^(.*%S)") or ""
    local comment_part = line:sub(s_start)

    -- 2. Считаем позиции
    local code_width = vim.fn.strdisplaywidth(clean_code)
    local current_col = vim.fn.strdisplaywidth(content_before) + 1

    -- 3. Вычисляем цель
    local target_col = current_col + (dir * 2)
    -- Выравнивание по нечётной сетке (51, 53...), если не уперлись в код
    if target_col % 2 == 0 then
        target_col = target_col + 1 -- Всегда сдвигаем на +1 для нечётности
    end

    -- 4. Граничное условие (минимум 1 пробел)
    local min_col = code_width + 2 -- Код + 1 пробел + 1 (начало коммента)
    if target_col < min_col then
        target_col = min_col       -- Тут сетка может нарушиться ради 1 пробела
    end
    -- Если позиция не изменилась (уперлись), ничего не обновляем
    if target_col == current_col then return end

    -- 5. Сборка строки
    local spaces_count = target_col - code_width - 1
    local new_line = clean_code .. string.rep(" ", spaces_count) .. comment_part
    vim.api.nvim_set_current_line(new_line)
    -- Опционально: двигаем курсор вместе с текстом, если он был на строке
    local cur = vim.api.nvim_win_get_cursor(0)
    if cur[2] >= #clean_code then
        vim.api.nvim_win_set_cursor(0, {cur[1], cur[2] + (target_col - current_col)})
    end
end

-- ==================== Горячие клавиши ====================
map('n', 'z', function() require('Comment.api').toggle.linewise.current() end, opts)
map('n', 'Z', aligned_comment, key_opts)
map({'n', 'i'}, '<M-,>', function() move_comment(-1) end, { desc = "Move comment Left" })
map({'n', 'i'}, '<M-.>', function() move_comment(1) end,  { desc = "Move comment Right" })
