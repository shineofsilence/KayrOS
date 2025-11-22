-- ===================================================================
-- 1. БАЗОВЫЕ НАСТРОЙКИ NEOVIM
-- ===================================================================
vim.g.mapleader = ' '               -- Устанавливаем <Leader> на пробел
vim.g.maplocalleader = ' '          -- Локально тоже

local opt = vim.opt
opt.autowrite = true                -- Автоматически сохранять при переключении буферов
opt.clipboard = 'unnamedplus'       -- Использовать системный буфер обмена
opt.completeopt = 'menu,menuone,noselect'
opt.confirm = true                  -- Спрашивать подтверждение, если есть несохраненные изменения
opt.cursorline = true               -- Подсвечивать текущую строку
opt.expandtab = true                -- Использовать пробелы вместо табуляции
opt.mouse = 'a'                     -- Включить поддержку мыши во всех режимах
opt.number = true                   -- Показывать номера строк
opt.relativenumber = true           -- Показывать относительные номера строк
opt.scrolloff = 8                   -- Оставлять 8 строк выше и ниже курсора при прокрутке
opt.sidescrolloff = 8               -- Оставлять 8 строк левее и правее курсора при прокрутке
opt.shiftwidth = 4                  -- Ширина отступа в 4 пробела
-- opt.showmode = false -- Не показывать текущий режим (это сделает статусная строка)
opt.ignorecase = true               -- Игнорировать регистр при поиске
opt.smartcase = true                -- Если в поиске есть заглавная буква, искать с учетом регистра
opt.tabstop = 2
opt.termguicolors = true            -- Включить 24-битные цвета
opt.timeoutlen = 300                -- Уменьшить задержку для <leader> команд
opt.undofile = true                 -- Сохранять историю изменений между сессиями
opt.wrap = false                    -- Отключить перенос строк
vim.opt.fileformat = 'unix'         -- Формат файлов из unix-систем

-- ===================================================================
-- 2. ПЕРЕОПРЕДЕЛЕНИЕ И ОЧИСТКА КОНФЛИКТУЮЩИХ ГОРЯЧИХ КЛАВИШ
-- ===================================================================
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true, desc = "Navigate window left" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true, desc = "Navigate window right" })

-- ===================================================================
-- 3. УСТАНОВКА МЕНЕДЖЕРА ПЛАГИНОВ (LAZY.NVIM)
-- ===================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ===================================================================
-- 4. СПИСОК И НАСТРОЙКА ПЛАГИНОВ
-- ===================================================================
require('lazy').setup({
    -- === ТЕМА ===
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000, -- Высокий приоритет, чтобы тема загружалась первой
        config = function()
            require('catppuccin').setup({
                -- Это та самая важная настройка для работы с фоном Kitty!
                transparent_background = true,
                -- Другие стили, если понадобятся
                styles = {
                    comments = { "italic" },
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
            })
            -- Применяем тему
            vim.cmd.colorscheme 'catppuccin'
        end,
    },
    
    -- === ФАЙЛОВЫЙ МЕНЕДЖЕР ===
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            "nvim-lua/plenary.nvim",        -- Обязательная зависимость
            "nvim-tree/nvim-web-devicons",  -- Для красивых иконок файлов
            "MunifTanjim/nui.nvim",         -- Интерфейс (Обязательная зависимость)
        },
        config = function()
            require('neo-tree').setup({
                close_if_last_window = true,
                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                    }
                }
            })
            vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle Neo-tree' })
        end,
    },
    
    -- === LSP, MASON и АВТОДОПОЛНЕНИЕ (САМОЕ ВАЖНОЕ) ===
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Mason управляет установкой серверов
            'williamboman/mason.nvim',
            -- Mason-LSPConfig связывает Mason и встроенный lspconfig
            'williamboman/mason-lspconfig.nvim', 

            -- Автодополнение
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'L3MON4D3/LuaSnip', -- Сниппеты (нужны для многих LSP)
        },
        config = function()
            -- 1. Инициализируем Mason (пусть качает бинарники)
            require('mason').setup()

            -- 2. Настраиваем "Capabilities" (чтобы Neovim сказал серверам: "я умею в автодополнение")
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- 3. Общая функция on_attach (бинды работают только если LSP активен)
            local on_attach = function(client, bufnr)
                local nmap = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc, silent = true })
                end
                nmap('<leader>R', vim.lsp.buf.rename, 'Rename')
                nmap('<leader>a', vim.lsp.buf.code_action, 'Code Action')
                nmap('gd', vim.lsp.buf.definition, 'Go to Definition')
                nmap('gr', function() require('telescope.builtin').lsp_references() end, 'Go to References')
                nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            end

            -- 4. Настраиваем Mason-LSPConfig (для ВСЕХ, КРОМЕ GLEAM)
            require('mason-lspconfig').setup({
                -- Сюда пишем всё, что Mason должен поставить сам
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
                    -- Стандартный обработчик: для каждого установленного сервера запускаем setup
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

            -- 5. Настраиваем GLEAM ВРУЧНУЮ (Нативный метод)
            -- Используем автокоманду для запуска LSP только в файлах .gleam
            -- Это полностью обходит ошибку deprecated
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

            -- 6. Настройка самого автодополнения (CMP)
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
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
   
    
    -- === TREESITTER - Подсветка синтаксиса ===
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                -- ДОБАВЛЕНЫ gleam и python
                ensure_installed = { 'gleam', 'python', 'lua', 'vim', 'bash', 'json', 'markdown' },
                highlight = { enable = true },
                indent = { enable = true },
            }
        end
    },
    -- === TELESCOPE (Поиск) ===
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            -- Оборачиваем require в функцию, чтобы вызов происходил только при нажатии
            { '<leader>f', function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
            { '<leader>g', function() require('telescope.builtin').live_grep() end, desc = 'Live Grep' },
            { '<leader>b', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
        },
    },
    -- === ДРУГИЕ ПОЛЕЗНЫЕ ПЛАГИНЫ ===
    { 'numToStr/Comment.nvim', opts = { }},                           -- Плагин добавления комментариев
})

