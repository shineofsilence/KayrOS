local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local config_path = vim.fn.stdpath('config')
package.path = package.path .. ';' .. config_path .. '/behavior/?.lua'
package.path = package.path .. ';' .. config_path .. '/controls/?.lua'

-- =================== Базовые настройки ===================
vim.g.mapleader = ' '                             -- Устанавливаем <Leader> на пробел
local opt = vim.opt                               -- Переопределяем для сокращения
vim.g.maplocalleader = ' '                        -- Локально тоже
opt.timeoutlen = 700                              -- Задержка команды
opt.autowrite = true                              -- Автоматически сохранять при переключении буферов
opt.clipboard = 'unnamedplus'                     -- Использовать системный буфер обмена
opt.completeopt = 'menu,menuone,noselect'
opt.confirm = true                                -- Спрашивать подтверждение, если есть несохраненные изменения
opt.undofile = true                               -- Сохранять историю изменений между сессиями
opt.mouse = 'a'                                   -- Включить поддержку мыши во всех режимах
opt.cursorline = true                             -- Подсвечивать текущую строку
opt.number = true                                 -- Показывать номера строк
opt.expandtab = true                              -- Использовать пробелы вместо табуляции
opt.shiftwidth = 4                                -- Ширина отступа в 4 пробела
opt.tabstop = 4                                   -- Табуляция в 4 пробела
opt.scrolloff = 8                                 -- Оставлять 8 строк выше и ниже курсора при прокрутке
opt.ignorecase = true                             -- Игнорировать регистр при поиске
opt.smartcase = true                              -- Если в поиске есть заглавная буква, искать с учетом регистра
opt.fileformat = 'unix'                           -- Формат файлов из unix-систем
opt.termguicolors = true                          -- Включить 24-битные цвета
opt.signcolumn = "number"                         -- Предупреждения поверх номеров строк
require('text_files')                             -- Перенос строк в текстовых файлах
require('magnet_scroll')                          -- Магнитный горизонтальный скролл

-- ==================== Кай-управление =====================
-- ------------------- Чистота РАСЫ --------------------
local alphabet = "abcdefghijklmnoqrsuvwxyzABCDEFGHIJKLMNORSTUVWXYZ"
for i = 1, #alphabet do
    local char = alphabet:sub(i, i)
    map({'n', 'v', 'x'}, char, '<Nop>', opts)
end
require('far_keys')                               -- Далёкие клавиши
require('movement')                               -- Перемещение
require('actions')                                -- Действия
require('formatting')                             -- Форматирование

-- ========= Установка менеджера плагинов LazyVim ==========
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
opt.rtp:prepend(lazypath)

-- ======================== Плагины ========================
require('lazy').setup({
    -- ------------------ Тема оформления ------------------
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({
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
            vim.cmd.colorscheme 'catppuccin'      -- Применяем тему
        end,
    },

    -- ----------------- Файловый менеджер -----------------
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            "nvim-lua/plenary.nvim",        -- Обязательная зависимость
            "nvim-tree/nvim-web-devicons",  -- Для красивых иконок файлов
            "MunifTanjim/nui.nvim",         -- Интерфейс
        },
        config = function()
            require('neo-tree').setup({
                close_if_last_window = true,
                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                    }
                },
                -- Настройка управления
                window = {
                    mappings = {
                        -- ================= Навигация =================
                        ["l"] = "open",           -- Открыть файл / Раскрыть папку
                        ["д"] = "open",           -- Открыть файл / Раскрыть папку
                        ["h"] = "close_node",     -- Закрыть папку / Подняться выше
                        ["р"] = "close_node",     -- Закрыть папку / Подняться выше
                        ["S"] = "none",           -- Отключаем сплиты
                        ["s"] = "none",           -- Отключаем сплиты

                        -- ================= Операции =================
                        ["g"] = "add",            -- Создать новый файл/папку
                        ["п"] = "add",            -- Создать новый файл/папку
                        ["t"] = "rename",         -- Переименовать
                        ["е"] = "rename",         -- Переименовать
                        ["c"] = "copy_to_clipboard", -- Копировать
                        ["с"] = "copy_to_clipboard", -- Копировать
                        ["x"] = "cut_to_clipboard", -- Вырезать
                        ["ч"] = "cut_to_clipboard", -- Вырезать
                        ["d"] = "delete",         -- Удалить
                        ["в"] = "delete",         -- Удалить
                        ["v"] = "paste_from_clipboard", -- Вставить
                        ["м"] = "paste_from_clipboard", -- Вставить
                        ["r"] = "refresh",        -- Обновить дерево
                        ["к"] = "refresh",        -- Обновить дерево
                        ["?"] = "show_help",      -- Помощь
                    }
                }
            })
        end,
    },

    -- --------------- LSP и автодополнение ----------------
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

    -- --- Подсветка синтаксиса и структуры - Treesitter ---
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

    -- ----------------- Telescope - поиск -----------------
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

    -- ---------- Плагин добавления комментариев -----------
    { 'numToStr/Comment.nvim', opts = { }},

    -- -------------- Движение по под-словам ---------------
    {
        "chrisgrieser/nvim-spider",
        lazy = false,
        config = function()
            require("spider").setup({
                skipInsignificantPunctuation = false,
                subwordMovement = true,
                customPatterns = {
                    -- %w       -> Латиница и цифры
                    -- \128-\255 -> Все UTF-8 символы (русский и др.)
                    -- Всё остальное (знаки, скобки, пробелы) игнорируется
                    "[%w\128-\255]+", 
                },
            })
        end,
    },

    -- - Автоматическая расстановка закрывающих спецсиволов -
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
})

