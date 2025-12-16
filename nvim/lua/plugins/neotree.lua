-- ----------------- Файловый менеджер -----------------
return {
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            "nvim-lua/plenary.nvim",                  -- Обязательная зависимость
            "nvim-tree/nvim-web-devicons",            -- Для красивых иконок файлов
            "MunifTanjim/nui.nvim",                   -- Интерфейс
        },
        config = function()
            -- ---------------- Поиск корня проекта ----------------
            local function get_project_root()
                local path = vim.fn.expand('%:p:h')
                if path == "" then return vim.fn.getcwd() end
                local cmd = 'git -C ' .. vim.fn.escape(path, ' ') .. ' rev-parse --show-toplevel'
                local git_root = vim.fn.systemlist(cmd)[1]
                if vim.v.shell_error == 0 and git_root then
                    return git_root
                end
                return path
            end
            require('neo-tree').setup({
                close_if_last_window = true,
                filesystem = {
                    use_libuv_file_watcher = true, -- Автоматически обновлять дерево при изменении файлов
                    bind_to_cwd = false,
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                    }
                },
                -- Настройка управления
                window = {
                    mappings = {
                        -- ================= Навигация =================
                        -- Вниз/Вверх на 4 строки
                        ["k"] = function() vim.cmd("normal! k") end,    -- Движение вверх
                        ["л"] = function() vim.cmd("normal! k") end,    -- Движение вверх
                        ["j"] = function() vim.cmd("normal! j") end,    -- Движение вниз
                        ["о"] = function() vim.cmd("normal! j") end,    -- Движение вниз
                        ["l"] = "open",                                 -- Открыть файл / Раскрыть папку
                        ["д"] = "open",                                 -- Открыть файл / Раскрыть папку
                        ["h"] = "close_node",                           -- Закрыть папку / Подняться выше
                        ["р"] = "close_node",                           -- Закрыть папку / Подняться выше
                        ["S"] = "none",                                 -- Отключаем сплиты
                        ["s"] = "none",                                 -- Отключаем сплиты

                        -- ================= Операции =================
                        ["g"] = "add",                                  -- Создать новый файл/папку
                        ["п"] = "add",                                  -- Создать новый файл/папку
                        ["t"] = "rename",                               -- Переименовать
                        ["е"] = "rename",                               -- Переименовать
                        ["c"] = "copy_to_clipboard",                    -- Копировать
                        ["с"] = "copy_to_clipboard",                    -- Копировать
                        ["x"] = "cut_to_clipboard",                     -- Вырезать
                        ["ч"] = "cut_to_clipboard",                     -- Вырезать
                        ["d"] = "delete",                               -- Удалить
                        ["в"] = "delete",                               -- Удалить
                        ["v"] = "paste_from_clipboard",                 -- Вставить
                        ["м"] = "paste_from_clipboard",                 -- Вставить
                        ["r"] = "refresh",                              -- Обновить дерево
                        ["к"] = "refresh",                              -- Обновить дерево
                        ["?"] = "show_help",                            -- Помощь
                    }
                }
            })
            -- ---------- Открытие: корень + текущий файл -----------
            local function toggle_smart()
                local root = get_project_root()
                require("neo-tree.command").execute({
                    toggle = true,                                -- Открыть/Закрыть
                    dir = root,                                   -- Установить корень Git
                    reveal = true,                                -- Найти и подсветить текущий файл
                    position = "left",
                })
            end
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', 'n', '<C-w>w', opts)              -- Переключить фокус (Файл <-> Дерево)
            vim.keymap.set('n', 'т', '<C-w>w', opts)              -- Переключить фокус (Файл <-> Дерево)
            vim.keymap.set('n', '<M-n>', toggle_smart, opts)      -- Открыть/Скрыть дерево файлов
            vim.keymap.set('n', '<M-т>', toggle_smart, opts)      -- Открыть/Скрыть дерево файлов
        end,
    }
}
