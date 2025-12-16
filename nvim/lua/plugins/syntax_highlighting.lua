    -- --- Подсветка синтаксиса и структуры - Treesitter ---
return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'gleam', 'python', 'lua', 'vim', 'bash', 'json', 'markdown' },
                highlight = { enable = true },
                indent = { enable = true },
                -- Настройка текстовых объектов (чтобы работали y, o, u, i)
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            -- Описываем, что считать "внутренностью" и "внешностью"
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ia"] = "@parameter.inner",
                            ["aa"] = "@parameter.outer",
                        },
                    },
                    move = {
                        enable = true, -- Это позволяет работать модулю move.lua
                        set_jumps = true, 
                    },
                },
            }
        end
    },
}