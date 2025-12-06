-- ==================== Магнитный Горизонтальный Скролл ====================
vim.opt.sidescrolloff = 0                         -- Отключаем стандартный скролл
local scroll_grp = vim.api.nvim_create_augroup("MagneticScroll", { clear = true })

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = scroll_grp,
    callback = function()
        -- 1. Настройки
        local pad = 15 -- Твой желаемый запас справа

        -- 2. Получаем геометрию окна
        local win = vim.api.nvim_get_current_win()
        local win_width = vim.api.nvim_win_get_width(win)

        -- Вычитаем ширину служебных колонок (номера строк, значки ошибок и т.д.)
        -- Чтобы получить чистую ширину текстовой области
        local text_off = vim.fn.getwininfo(win)[1].textoff
        local text_area = win_width - text_off

        -- 3. Получаем текущую позицию
        local view = vim.fn.winsaveview()
        local cur_left = view.leftcol

        -- Используем виртуальную колонку (учитывает табы и UTF-8), а не байты
        -- virtcol('.') возвращает 1-based индекс, делаем 0-based
        local cur_vcol = vim.fn.virtcol('.') - 1

        -- 4. Расчет идеального левого края
        -- Логика: Экран должен быть сдвинут вправо МИНИМУМ настолько, 
        -- чтобы курсор влезал в text_area минус pad.
        -- Но не меньше 0.

        -- Формула: Если курсор на 100, ширина 80, пад 15.
        -- Видимое место под курсор: 80 - 15 = 65.
        -- Смещение должно быть: 100 - 65 = 35.
        -- Тогда экран покажет с 35 по 115. Курсор (100) будет на позиции 65 (от начала экрана).

        local max_cursor_screen_pos = text_area - pad
        local target_left = cur_vcol - max_cursor_screen_pos

        if target_left < 0 then target_left = 0 end

        -- 5. Применение
        -- Если расчетное положение отличается от текущего -> двигаем экран.
        -- Это работает в обе стороны:
        -- Вправо: target_left растет, толкая экран.
        -- Влево: target_left падает МГНОВЕННО вслед за курсором.
        if target_left ~= cur_left then
            view.leftcol = target_left
            vim.fn.winrestview(view)
        end
    end
})
