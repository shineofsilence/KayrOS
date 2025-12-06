-- ПРАВда там, где сердце. С какой стороны сердце? ПРАВильно: с ПРАВой.
-- Выбирайся из этого королевства кривых зеркал, дружок.

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local cmd_opts = { noremap = true, silent = false }
local symbols = { "'", '"', "(", ")", "[", "]", "{", "}" }

-- ==================== Чистота расы ====================
local alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i = 1, #alphabet do
    local char = alphabet:sub(i, i)
    map({'n', 'v'}, char, '<Nop>', opts)
end

-- ============ Переопределяем далёкие клавиши ==========
map({'i', 'v', 'c'}, '<M-p>', '<Esc>', opts)      -- Выход в обзорный режим

-- ------------------ Обзорный режим -------------------
map('n', '<M-j>', 'X', opts)                      -- Backspace
map('n', '<M-k>', 'x', opts)                      -- Delete

-- --------------- Режим редактирования ----------------
map('i', '<M-h>', '<Left>', opts)                 -- Направо
map('i', '<M-l>', '<Right>', opts)                -- Налево
map('i', '<C-h>', '<C-Left>', opts)               -- Направо по словам
map('i', '<C-l>', '<C-Right>', opts)              -- Налево по словам
map('i', '<M-j>', '<BS>', opts)                   -- Backcpace
map('i', '<M-k>', '<Del>', opts)                  -- Delete

-- ------------------- Режим команд --------------------
map('c', '<M-h>', '<Left>', cmd_opts)             -- Направо
map('c', '<M-l>', '<Right>', cmd_opts)            -- Налево
map('c', '<C-h>', '<C-Left>', cmd_opts)           -- Направо по словам
map('c', '<C-l>', '<C-Right>', cmd_opts)          -- Налево по словам
map('c', '<M-j>', '<BS>', cmd_opts)               -- Backspace
map('c', '<M-k>', '<Del>', cmd_opts)              -- Delete

-- ====================== Перемещение ======================
-- ---------------------- Вправо -----------------------
map({'n', 'v'}, 'h', 'h', opts)                   -- Вправо на символ
map({'n', 'o', 'x'}, 'H', function() require("spider").motion("b") end, opts) -- Вправо по началам слов
map({'n', 'v'}, 'y', '^', opts)                   -- В начало строки (первый символ)

-- ----------------------- Влево -----------------------
map({'n', 'v'}, 'l', 'l', opts)                   -- Влево на символ
map({'n', 'o', 'x'}, 'L', function() require("spider").motion("w") end, opts) -- Влево по началам слов
map({'n', 'v'}, 'o', '$', opts)                   -- В конец строки

-- ----------------------- Вверх -----------------------
map({'n', 'v'}, 'k', 'k', opts)                   -- Вверх к началу строки
map({'n', 'v'}, 'K', '3k', opts)                  -- 3 строки вверх к началу
map({'n', 'v'}, 'u', '}', opts)                   -- Параграф вверх
map({'n', 'v'}, 'U', 'G', opts)                   -- В начало файла

-- ----------------------- Вниз ------------------------
map({'n', 'v'}, 'j', 'j', opts)                   -- Вниз к началу строки
map({'n', 'v'}, 'J', '3j', opts)                  -- 3 строки вниз к началу
map({'n', 'v'}, 'i', '{', opts)                   -- Параграф вниз
map({'n', 'v'}, 'I', 'gg', opts)                  -- В конец файла

-- --------------- Скачок к спецсимволам ---------------
map('n', '(', '/(<CR>', opts)                     -- Найти следующую (
map('n', ')', '/)<CR>', opts)                     -- Найти следующую )
map('n', '{', '/{<CR>', opts)                     -- Найти следующую {
map('n', '}', '/}<CR>', opts)                     -- Найти следующую }
map('n', '[', '/[<CR>', opts)                     -- Найти следующую [
map('n', ']', '/]<CR>', opts)                     -- Найти следующую ]
map('n', '"', '/"<CR>', opts)                     -- Найти следующую "
map('n', "'", "/'<CR>", opts)                     -- Найти следующую '
map('n', ",", "/,<CR>", opts)                     -- Найти следующую ,

-- ----------------------- Поиск -----------------------
map('n', '/', '/', opts)                          -- Поиск по файлу (вперед)
map('n', '?', function() require('telescope.builtin').live_grep() end, opts) -- Поиск по проекту (Grep)
map('n', 'p', function() require('telescope.builtin').lsp_references() end, opts) -- Поиск использований (References)
map('n', 'P', vim.lsp.buf.definition, opts)       -- Перейти к определению (Definition)
map('n', 'm', 'n', opts)                          -- Следующее совпадение
map('n', 'M', 'N', opts)                          -- Предыдущее совпадение

-- ---------------------- Сдвиги -----------------------
map('n', '<', '<<', opts)                         -- Сдвиг вправо
map('n', '>', '>>', opts)                         -- Сдвиг влево

-- ------------------ Дерево проекта -------------------
map('n', 'n', '<C-w>w', opts)                     -- Переключить фокус (Файл <-> Дерево)
map('n', 'N', '<cmd>Neotree toggle<CR>', opts)    -- Открыть/Скрыть дерево файлов

-- ======================= Действия ========================
-- -------------------- Режим выделения -------------------
map('n', 'f', 'v', opts)                          -- Обычный вход
map('v', 'c', 'y', opts)                          -- Копировать
map('v', 'C', 'Y', opts)                          -- Копировать строки
map('v', 's', 'c', opts)                          -- Корректировать
map('v', 'S', 'Vc', opts)                         -- Корректировать строки
map('v', 'd', 'd', opts)                          -- Удалить
map('v', 'D', 'Vd', opts)                         -- Удалить строки

-- ------------------- Режим обзора --------------------
map('n', 'v', 'p', opts)                          -- Вставить из буфера после
map('n', 'V', 'P', opts)                          -- Вставить из буфера до

map('n', 'aw', 'i', opts)                         -- Редактировать до символа
map('n', 'ae', 'ea', opts)                        -- Редактировать после слова
map('n', 'ar', 'A', opts)                         -- Редактировать в конце строки

map('n', 'cw', 'yl', opts)                        -- Копировать символ
map('n', 'ce', 'yiw', opts)                       -- Копировать слово
map('n', 'cr', 'yy', opts)                        -- Копировать строку

map('n', 'sw', 's', opts)                         -- Корректировать символ
map('n', 'se', 'ciw', opts)                       -- Корректировать слово
map('n', 'sr', 'cc', opts)                        -- Корректировать строку

map('n', 'dw', 'x', opts)                         -- Удалить символ
map('n', 'de', 'diw', opts)                       -- Удалить слово
map('n', 'dr', 'dd', opts)                        -- Удалить строку

for _, sym in ipairs(symbols) do
    local text_obj = sym
    if sym == "{" or sym == "}" then text_obj = "B" end
    map('n', 'f' .. sym, 'vi' .. text_obj, opts)              -- Вход в выделение
    map('n', 'c' .. sym, 'yi' .. text_obj, opts)              -- Скопировать
    map('n', 's' .. sym, 'ci' .. text_obj, opts)              -- Корректировать
    map('n', 'd' .. sym, 'di' .. text_obj, opts)              -- Удалить
    map('n', 'a' .. sym, 'vi' .. text_obj .. '<Esc>a', opts)  -- Редактировать после содержимого
end

-- --------------- Вставка пустых строк ----------------
local function smart_newline(direction)
    -- Получаем текущую строку и курсор
    local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- "Воруем" отступ (всё от начала строки до первого непробельного символа)
    local indent = line:match("^(%s*)") or ""
    -- Определяем позицию вставки
    -- API nvim_buf_set_lines использует 0-индексацию
    local start_row = (direction == 'below') and r or r - 1
    -- Вставляем строку с отступом
    vim.api.nvim_buf_set_lines(0, start_row, start_row, false, {indent})
    -- Перемещаем курсор на новую строку в конец отступа
    local new_row = (direction == 'below') and r + 1 or r
    -- new_row для win_set_cursor - 1-индексация
    vim.api.nvim_win_set_cursor(0, {new_row, #indent})
end
map('n', 'g', function() smart_newline('below') end, opts)  -- Пустая строка после
map('n', 'G', function() smart_newline('above') end, opts)  -- Пустая строка до

-- ---------------------- Разное -----------------------
map('n', 'q', '<cmd>nohl<CR>', opts)                         -- Снять выделение поиска
map('n', 't', vim.lsp.buf.rename, opts)                      -- Переименовать переменную
map('n', 'b', 'u', opts)                                     -- Отмена действия (Undo)
map('n', 'B', '<C-r>', opts)                                 -- Повтор действия (Redo)
