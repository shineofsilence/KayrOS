vim.opt.wrap = false                              -- Отключаем перенос строк глобально
-- ================== Настройки для текстовых файлов ==================
vim.api.nvim_create_autocmd("FileType", {
    -- Группа нужна, чтобы не дублировать событие при перезагрузках конфига
    group = vim.api.nvim_create_augroup("KayTextSettings", { clear = true }),
    -- Список типов файлов. Можно добавить 'gitcommit', 'tex' и т.д.
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        -- Применяем настройки ТОЛЬКО к текущему буферу (local)
        vim.opt_local.wrap = true          -- Включить перенос строк
        vim.opt_local.linebreak = true     -- Переносить только по словам (не резать слова)
        vim.opt_local.breakindent = true   -- Сохранять отступ при переносе (полезно для списков)
    end,
})
