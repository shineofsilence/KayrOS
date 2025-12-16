    -- ----------------- Встроенный терминал -----------------
return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            -- 1. Настройка внешнего вида (БЕЗ open_mapping и БЕЗ dir)
            require("toggleterm").setup({
                size = 5,
                hide_numbers = true,
                shade_terminals = true,
                start_in_insert = true,
                insert_mappings = true,   -- Разрешаем использовать бинды в insert mode
                persist_size = true,
                direction = 'horizontal',
                shell = vim.o.shell,
            })

            -- 2. Функция поиска корня (наша отлаженная)
            local function get_project_root()
                local path = vim.fn.expand('%:p:h')
                if path == "" then return vim.fn.getcwd() end
                -- Спрашиваем у git
                local cmd = 'git -C ' .. vim.fn.escape(path, ' ') .. ' rev-parse --show-toplevel'
                local git_root = vim.fn.systemlist(cmd)[1]
                if vim.v.shell_error == 0 and git_root then
                    return git_root
                end
                return path -- Или vim.fn.getcwd(), если хочешь корень сессии
            end

            -- 3. Умный Тоггл (Собственная функция)
            _G.toggle_project_term = function()
                local root = get_project_root()
                -- Вызываем ToggleTerm, явно передавая ему dir
                -- toggle(count, size, dir, direction)
                require("toggleterm").toggle(1, 15, root, 'horizontal')
            end

            -- 4. Назначаем горячую клавишу (Alt + y)
            local opts = { noremap = true, silent = true }
            vim.keymap.set({'n', 't', 'i'}, '<M-y>', '<cmd>lua _G.toggle_project_term()<CR>', opts)

            -- 5. Бинды навигации внутри терминала
            function _G.set_terminal_keymaps()
                local opts = {buffer = 0}
                vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
                vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
                -- Русские
                vim.keymap.set('t', '<C-р>', [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set('t', '<C-о>', [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set('t', '<C-л>', [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set('t', '<C-д>', [[<Cmd>wincmd l<CR>]], opts)
            end
            vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
        end
    },
}
