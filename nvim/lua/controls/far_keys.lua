local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local cmd_opts = { noremap = true, silent = false }

-- ============ Переопределяем далёкие клавиши ==========
map({'i', 'v', 'c'}, '<M-p>', '<Esc>', opts)      -- Выход в обзорный режим
map({'i', 'v', 'c'}, '<M-з>', '<Esc>', opts)      -- Выход в обзорный режим

-- ------------------ Обзорный режим -------------------
map('n', '<M-j>', 'X', opts)                      -- Backspace
map('n', '<M-о>', 'X', opts)                      -- Backspace
map('n', '<M-k>', 'x', opts)                      -- Delete
map('n', '<M-л>', 'x', opts)                      -- Delete

-- --------------- Режим редактирования ----------------
map('i', '<M-h>', '<Left>', opts)                 -- Направо
map('i', '<M-р>', '<Left>', opts)                 -- Направо
map('i', '<M-l>', '<Right>', opts)                -- Налево
map('i', '<M-д>', '<Right>', opts)                -- Налево
map('i', '<C-h>', '<C-Left>', opts)               -- Направо по словам
map('i', '<C-р>', '<C-Left>', opts)               -- Направо по словам
map('i', '<C-l>', '<C-Right>', opts)              -- Налево по словам
map('i', '<C-д>', '<C-Right>', opts)              -- Налево по словам
map('i', '<M-j>', '<BS>', opts)                   -- Backcpace
map('i', '<M-о>', '<BS>', opts)                   -- Backcpace
map('i', '<M-k>', '<Del>', opts)                  -- Delete
map('i', '<M-л>', '<Del>', opts)                  -- Delete

-- ------------------- Режим команд --------------------
map('c', '<M-h>', '<Left>', cmd_opts)             -- Направо
map('c', '<M-р>', '<Left>', cmd_opts)             -- Направо
map('c', '<M-l>', '<Right>', cmd_opts)            -- Налево
map('c', '<M-д>', '<Right>', cmd_opts)            -- Налево
map('c', '<C-h>', '<C-Left>', cmd_opts)           -- Направо по словам
map('c', '<C-р>', '<C-Left>', cmd_opts)           -- Направо по словам
map('c', '<C-l>', '<C-Right>', cmd_opts)          -- Налево по словам
map('c', '<C-д>', '<C-Right>', cmd_opts)          -- Налево по словам
map('c', '<M-j>', '<BS>', cmd_opts)               -- Backspace
map('c', '<M-о>', '<BS>', cmd_opts)               -- Backspace
map('c', '<M-k>', '<Del>', cmd_opts)              -- Delete
map('c', '<M-л>', '<Del>', cmd_opts)              -- Delete

