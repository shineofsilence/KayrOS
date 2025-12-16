 -- --------------- LSP и автодополнение ----------------
 return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',            -- Mason - менеджер LSP
            'williamboman/mason-lspconfig.nvim',  -- Связь mason и встренного lspconfig
            -- Автодополнение
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip',                   -- Сниппеты
        },
        config = function()
            -- 1. Инициализируем Mason
            require('mason').setup()

            -- 2. Указываем искать корень проекта в текущей папке
            local util = require('lspconfig.util')
            util.default_config.root_dir = function(fname)
                -- 1. Сначала ищем стандартные маркеры (.git, package.json и т.д.)
                local found = util.root_pattern(".git", "package.json", "Makefile", "pyproject.toml", "gleam.toml")(fname)
                -- 2. Если маркеров нет — возвращаем текущую рабочую папку (cwd)
                -- Это предотвращает панику сервера
                return found or vim.loop.cwd()
            end

            -- 3. Настраиваем "Capabilities"
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- 4. Общая функция on_attach
            local on_attach = function(client, bufnr) end

            -- 5. Настраиваем Mason-LSPConfig
            require('mason-lspconfig').setup({
                -- ----------- Список LSP-серверов от mason ------------
                ensure_installed = {
                    'pyright',
                    'bashls',
                    'dockerls',
                    'jsonls',
                    'yamlls',
                    'ts_ls',
                    'lua_ls'
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                        })
                    end,
                    -- Пример настройки Lua (чтобы не ругался на глобальную переменную vim)
                    ["lua_ls"] = function()
                        require('lspconfig').lua_ls.setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = { Lua = { diagnostics = { globals = {'vim'} } } }
                        })
                    end,
                }
            })

            -- 5. Настраиваем GLEAM стандартным методом
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "gleam",
                callback = function(ev)
                    vim.lsp.start({
                        name = "gleam",
                        cmd = { "gleam", "lsp" },
                        -- Ищем корень проекта по gleam.toml или .git
                        root_dir = vim.fs.dirname(vim.fs.find({'gleam.toml', '.git'}, { upward = true })[1]),
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
            })

            -- 6. Настройка  автодополнения (CMP)
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            cmp.setup({
                -- ОТКЛЮЧАЕМ автоматическое выпадение
                completion = {
                    autocomplete = false 
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end,
    },
}