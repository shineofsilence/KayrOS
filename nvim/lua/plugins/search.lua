-- ----------------- Telescope - поиск -----------------
return {
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local actions = require('telescope.actions')
            require('telescope').setup({
                defaults = {
                    -- Навигация внутри окна (работает и в Insert, и в Normal режиме окна)
                    mappings = {
                        i = { -- Режим ввода (по умолчанию)
                            -- Вниз (j / о)
                            ["<M-j>"] = actions.move_selection_next,
                            ["<M-о>"] = actions.move_selection_next,
                            -- Вверх (k / л)
                            ["<M-k>"] = actions.move_selection_previous,
                            ["<M-л>"] = actions.move_selection_previous,
                            -- Выбрать (l / д) -> Select Default
                            ["<M-l>"] = actions.select_default,
                            ["<M-д>"] = actions.select_default,
                            -- Закрыть (p / з)
                            ["<M-p>"] = actions.close,
                            ["<M-з>"] = actions.close,
                        },
                        n = { -- Normal режим (если вдруг нажмешь Esc внутри)
                            ["<M-j>"] = actions.move_selection_next,
                            ["<M-о>"] = actions.move_selection_next,
                            ["<M-k>"] = actions.move_selection_previous,
                            ["<M-л>"] = actions.move_selection_previous,
                            ["<M-l>"] = actions.select_default,
                            ["<M-д>"] = actions.select_default,
                            ["<M-p>"] = actions.close,
                            ["<M-з>"] = actions.close,
                        },
                    },
                },
            })
        end,
    },
}
