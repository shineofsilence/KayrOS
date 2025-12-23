-- ====================== Сокращения =======================
local map = vim.keymap.set
local opt = vim.opt
local opts = { noremap = true, silent = true }
  
-- =================== Базовые настройки ===================
opt.timeoutlen = 1000                             -- Задержка команды
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
opt.laststatus = 3                                -- Общий статус буферов
opt.fillchars = { vert = "│", eob = " " }         -- Оформление буферов
opt.signcolumn = "number"                         -- Предупреждения поверх номеров строк
opt.foldmethod = "expr"                           -- Метод сворачивания
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- Исполнитель сворачивания
opt.foldlevel = 99                                -- Открывать файлы полностью развернутыми (0 - всё свернуто)
opt.foldlevelstart = 99                           -- Начинать с развернутого состояния
opt.foldenable = true                             -- Включить саму возможность сворачивания
opt.foldcolumn = "0"                              -- Не показывать лишнюю колонку слева (если хочешь видеть галочки, ставь "1")
require('behavior.text_files')                    -- Перенос строк в текстовых файлах
require('behavior.magnet_scroll')                 -- Магнитный горизонтальный скролл

-- ==================== Кай-управление =====================
-- ------------------- Чистота РАСЫ --------------------
local alphabet = "abcdefghijklmnoqrsuvwxyzABCDEFGHIJKLMNORSTUVWXYZ"
for i = 1, #alphabet do
    local char = alphabet:sub(i, i)
    map({'n', 'v', 'x'}, char, '<Nop>', opts)
end
require('controls.far_keys')                      -- Далёкие клавиши
require('controls.movement')                      -- Перемещение
require('controls.actions')                       -- Действия
require('controls.formatting')                    -- Форматирование

-- =================== LazyVim и плагины ===================
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

-- ---------------- Установка плагинов -----------------
require("lazy").setup({
        { import = "plugins" },                   -- Папка с плагинами
	},
	{
        ui = { border = "rounded", },             -- Рамка для окна lazy
        checker = { enabled = true },             -- Автоматически проверять обновления
    }
)
