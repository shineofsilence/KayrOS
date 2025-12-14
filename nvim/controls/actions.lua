-- ----------- Функция переназначения клавиш -----------
local function buf_map(mode, key, rhs)
    vim.keymap.set(mode, key, rhs, { noremap = true, silent = true, nowait = true, buffer = 0 })
end

-- ==================== Горячие клавиши ====================
local function apply_actions_binds()
    -- ============== Действия в обзорном режиме ===============
    buf_map('n', 'a', 'a')                            -- Редактировать после курсора
    buf_map('n', 'ф', 'a')                            -- Редактировать после курсора
    buf_map('n', 'A', 'i')                            -- Редактировать до курсора
    buf_map('n', 'Ф', 'i')                            -- Редактировать до курсора
    buf_map('n', 'c', 'yy')                           -- Копировать строку
    buf_map('n', 'с', 'yy')                           -- Копировать строку
    buf_map('n', 'v', 'p')                            -- Вставить до курсора
    buf_map('n', 'м', 'p')                            -- Вставить до курсора
    buf_map('n', 'V', 'P')                            -- Вставить после курсора
    buf_map('n', 'М', 'P')                            -- Вставить после курсора

    -- ----------------------- Поиск -----------------------
    buf_map('n', '/', '/')                            -- Поиск по файлу (вперед)
    buf_map('n', '?', function() require('telescope.builtin').live_grep() end) -- Поиск по проекту (Grep)
    buf_map('n', 'p', function() require('telescope.builtin').lsp_references() end) -- Поиск использований (References)
    buf_map('n', 'з', function() require('telescope.builtin').lsp_references() end) -- Поиск использований (References)
    buf_map('n', 'P', vim.lsp.buf.definition)         -- Перейти к определению (Definition)
    buf_map('n', 'З', vim.lsp.buf.definition)         -- Перейти к определению (Definition)
    buf_map('n', 'm', 'n')                            -- Следующее совпадение
    buf_map('n', 'ь', 'n')                            -- Следующее совпадение
    buf_map('n', 'M', 'N')                            -- Предыдущее совпадение
    buf_map('n', 'Ь', 'N')                            -- Предыдущее совпадение
    buf_map('n', 'q', '<cmd>nohl<CR>')                -- Снять выделение поиска
    buf_map('n', 'й', '<cmd>nohl<CR>')                -- Снять выделение поиска

    -- ------------------ Дерево проекта -------------------
    buf_map('n', 'n', '<C-w>w')                       -- Переключить фокус (Файл <-> Дерево)
    buf_map('n', 'т', '<C-w>w')                       -- Переключить фокус (Файл <-> Дерево)
    buf_map('n', 'N', '<cmd>Neotree toggle<CR>')      -- Открыть/Скрыть дерево файлов
    buf_map('n', 'Т', '<cmd>Neotree toggle<CR>')      -- Открыть/Скрыть дерево файлов

    -- --------------- Языковой сервер (LSP) ---------------
    buf_map('n', 'P', vim.lsp.buf.definition)         -- Перейти к определению
    buf_map('n', 'З', vim.lsp.buf.definition)         -- Перейти к определению
    buf_map('n', 'p', function() require('telescope.builtin').lsp_references() end) -- Поиск использований
    buf_map('n', 'з', function() require('telescope.builtin').lsp_references() end) -- Поиск использований
    buf_map('n', '<M-t>', vim.lsp.buf.hover)          -- Документация
    buf_map('n', '<M-е>', vim.lsp.buf.hover)          -- Документация
    buf_map('n', 't', vim.lsp.buf.rename)             -- Переименование
    buf_map('n', 'е', vim.lsp.buf.rename)             -- Переименование
    buf_map('n', 'T', vim.lsp.buf.code_action)        -- Действия
    buf_map('n', 'Е', vim.lsp.buf.code_action)        -- Действия

    -- -------------- Отмена/повтор действий ---------------
    buf_map('n', 'b', 'u')                            -- Отмена действия (Undo)
    buf_map('n', 'и', 'u')                            -- Отмена действия (Undo)
    buf_map('n', 'B', '<C-r>')                        -- Повтор действия (Redo)
    buf_map('n', 'И', '<C-r>')                        -- Повтор действия (Redo)
    buf_map('n', '<M-b>', '<C-o>')                    -- Назад по цепочке файлов
    buf_map('n', '<M-и>', '<C-o>')                    -- Назад по цепочке файлов
    buf_map('n', '<M-B>', '<C-i>')                    -- Вперёд по цепочке файлов
    buf_map('n', '<M-И>', '<C-i>')                    -- Вперёд по цепочке файлов

    -- ==================== Режим выделения ====================
    buf_map('v', 'm', 'o')                            -- Поменять активную сторону выделения
    buf_map('v', 'ь', 'o')                            -- Поменять активную сторону выделения
    buf_map('v', 'a', 'I')                            -- Редактировать до
    buf_map('v', 'ф', 'I')                            -- Редактировать до
    buf_map('v', 'A', 'A')                            -- Редактировать после
    buf_map('v', 'Ф', 'A')                            -- Редактировать после
    buf_map('v', 's', 'c')                            -- Корректировать
    buf_map('v', 'ы', 'c')                            -- Корректировать
    buf_map('v', 'S', 'Vc')                           -- Корректировать строки
    buf_map('v', 'Ы', 'Vc')                           -- Корректировать строки
    buf_map('v', 'd', 'd')                            -- Удалить
    buf_map('v', 'в', 'd')                            -- Удалить
    buf_map('v', 'D', 'Vd')                           -- Удалить строки
    buf_map('v', 'В', 'Vd')                           -- Удалить строки
    buf_map('v', 'c', 'y')                            -- Копировать
    buf_map('v', 'с', 'y')                            -- Копировать
    buf_map('v', 'C', 'Vy')                           -- Копировать строки
    buf_map('v', 'С', 'Vy')                           -- Копировать строки
    buf_map('v', 'v', 'p')                            -- Вставить из буфера с заменой
    buf_map('v', 'м', 'p')                            -- Вставить из буфера с заменой
    buf_map('v', 'V', 'Vp')                           -- Вставить из буфера с заменой строк
    buf_map('v', 'М', 'Vp')                           -- Вставить из буфера с заменой строк
end

-- -------- Применение биндов при входе в буфер --------
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("KayActions", { clear = true }),
    pattern = "*",
    callback = apply_actions_binds
})
apply_actions_binds()                            -- Применяем один раз сразу

