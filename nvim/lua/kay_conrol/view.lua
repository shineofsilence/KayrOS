local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- === НАВИГАЦИЯ: ГОРИЗОНТАЛЬ ===
map('n', 'h', 'h', opts)                                     -- Влево на символ
map('n', 'l', 'l', opts)                                     -- Вправо на символ
map('n', 'H', 'b', opts)                                     -- Влево по началу слова
map('n', 'L', 'w', opts)                                     -- Вправо по началу слова

-- Навигация по аргументам (Требует nvim-treesitter-textobjects)
map('n', 'y', function() require("nvim-treesitter.textobjects.move").goto_previous_start("@parameter.inner") end, opts) -- Предыдущий аргумент
map('n', 'o', function() require("nvim-treesitter.textobjects.move").goto_next_start("@parameter.inner") end, opts)     -- Следующий аргумент

map('n', 'Y', '^', opts)                                     -- В начало строки (первый символ)
map('n', 'O', '$', opts)                                     -- В конец строки


-- Мгновенный скачок к скобкам и кавычкам (Поиск символа + Enter)
map('n', '(', '/(<CR>', opts)                                -- Найти следующую (
map('n', ')', '/)<CR>', opts)                                -- Найти следующую )
map('n', '{', '/{<CR>', opts)                                -- Найти следующую {
map('n', '}', '/}<CR>', opts)                                -- Найти следующую }
map('n', '[', '/[<CR>', opts)                                -- Найти следующую [
map('n', ']', '/]<CR>', opts)                                -- Найти следующую ]
map('n', '"', '/"<CR>', opts)                                -- Найти следующую "
map('n', "'", "/'<CR>", opts)                                -- Найти следующую '

-- === НАВИГАЦИЯ: ВЕРТИКАЛЬ (СО СБРОСОМ В НАЧАЛО СТРОКИ) ===
map('n', 'j', '+', opts)                                     -- Вниз к началу строки
map('n', 'k', '-', opts)                                     -- Вверх к началу строки
map('n', 'J', '3+', opts)                                    -- 3 строки вниз к началу
map('n', 'K', '3-', opts)                                    -- 3 строки вверх к началу

-- Навигация по блокам кода (Требует nvim-treesitter-textobjects)
map('n', 'u', function() require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer") end, opts)  -- Начало предыдущей функции
map('n', 'i', function() require("nvim-treesitter.textobjects.move").goto_next_start("@function.outer") end, opts)      -- Начало следующей функции

map('n', 'U', 'gg', opts)                                    -- В начало файла
map('n', 'I', 'G', opts)                                     -- В конец файла

-- === ПОИСК ===
-- map('n', 'f', function() require("flash").jump() end, opts)  -- Flash-поиск (телепорт)
map('n', '/', '/', opts)                                     -- Поиск по файлу (вперед)
map('n', '?', function() require('telescope.builtin').live_grep() end, opts) -- Поиск по проекту (Grep)
map('n', 'm', 'n', opts)                                     -- Следующее совпадение
map('n', 'M', 'N', opts)                                     -- Предыдущее совпадение
map('n', 'q', '<cmd>nohl<CR>', opts)                         -- Снять выделение поиска

-- === ДЕЙСТВИЯ ===
map('n', '<', '<<', opts)                                    -- Сдвиг влево
map('n', '>', '>>', opts)                                    -- Сдвиг вправо
map('n', 's', 'yiw', opts)                                   -- Скопировать слово
map('n', 'S', 'yy', opts)                                    -- Скопировать строку
map('n', 'x', 'x', opts)                                     -- Удалить символ
map('n', 'd', 'diw', opts)                                   -- Удалить слово
map('n', 'D', 'dd', opts)                                    -- Удалить строку

map('n', 'g', 'gcc', { remap = true })                       -- Комментировать строку

-- Функция для добавления комментария на 60-й колонке
local function aligned_comment()
    local target_col = 60
    local current_len = vim.fn.col('$') - 1
    local spaces = math.max(1, target_col - current_len)
    vim.cmd("normal! A" .. string.rep(" ", spaces))
    -- Запускаем gcc на текущей строке, чтобы добавить символ комментария, затем в режим вставки
    require('Comment.api').toggle.linewise.current()
    vim.cmd("startinsert!") 
end
map('n', 'G', aligned_comment, opts)                         -- Комментарий с отступом справа

-- === ФАЙЛЫ И ПРОЕКТ ===
map('n', 'z', 'u', opts)                                     -- Отмена действия (Undo)
map('n', 'Z', '<C-r>', opts)                                 -- Повтор действия (Redo)
map('n', 'n', '<C-w>w', opts)                                -- Переключить фокус (Файл <-> Дерево)
map('n', 'N', '<cmd>Neotree toggle<CR>', opts)               -- Открыть/Скрыть дерево файлов
map('n', 'p', function() require('telescope.builtin').lsp_references() end, opts) -- Поиск использований (References)
map('n', 'P', vim.lsp.buf.definition, opts)                  -- Перейти к определению (Definition)
map('n', 'r', vim.lsp.buf.rename, opts)                      -- Переименовать переменную

-- === ПЕРЕХОДЫ В РЕЖИМЫ ===
map('n', 'v', 'v', opts)                                     -- Выделение символьное
map('n', 'V', 'viw', opts)                                   -- Выделение слова (сразу выделяет текущее)
map('n', 'X', 'r', opts)                                     -- Замена одного символа
map('n', 'w', 'i', opts)                                     -- Редактировать до курсора
map('n', 'e', 'a', opts)                                     -- Редактировать после курсора
map('n', 'W', 'bi', opts)                                    -- Редактировать до слова
map('n', 'E', 'ea', opts)                                    -- Редактировать после слова
map('n', 'c', 'ciw', opts)                                   -- Коррекция слова (удалить и вставка)
map('n', 'C', 'cc', opts)                                    -- Коррекция строки (удалить и вставка)
map('n', 't', 'O', opts)                                     -- Новая строка сверху
map('n', 'T', 'o', opts)                                     -- Новая строка снизу
