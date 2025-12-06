local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ======= Функция оформления комментариев разделов ========
local function create_section_comment(is_large)
    local line = vim.api.nvim_get_current_line()

    -- Получаем символ комментария
    local cms = vim.bo.commentstring
    if not cms or cms == "" then cms = "# %s" end
    local comment_char = vim.trim(vim.split(cms, "%s")[1])

    -- Настройки оформления
    local target_width = is_large and 60 or 56
    local deco_char = is_large and "=" or "-"

    -- Паттерн: ищем строку, которая является разделом (любым: - или =)
    -- [%-=]+ означает "один и более символов - или ="
    local esc_cc = comment_char:gsub("([^%w])", "%%%1")
    local any_section_pattern = "^%s*" .. esc_cc .. "%s*[%-=]+"

    -- 0. Валидация: если строка не пуста И это не раздел -> выход
    if not line:match("^%s*$") and not line:match(any_section_pattern) then
        return
    end
    local indent = line:match("^(%s*)") or ""

    -- 1. Ввод названия
    local title = vim.fn.input(is_large and "Section: " or "Subsection: ")
    if title == "" then return end

    -- 2. Расчет визуальной ширины (UTF-8 safe)
    local title_width = vim.fn.strdisplaywidth(title)
    local comm_width = vim.fn.strdisplaywidth(comment_char)

    -- 3-5. Математика отступов
    -- Overhead: Пробел_до + Пробел_после + Пробел_после_коммента
    local overhead = comm_width + 3 
    local available = target_width - title_width - overhead
    if available < 2 then available = 2 end
    local left_len = math.floor(available / 2)
    local right_len = available - left_len

    -- 7. Сборка
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

-- ==================== Горячие клавиши ====================
map('n', 'x', function() create_section_comment(false) end, opts) -- Малый (-)
map('n', 'X', function() create_section_comment(true) end, opts)  -- Большой (=)
