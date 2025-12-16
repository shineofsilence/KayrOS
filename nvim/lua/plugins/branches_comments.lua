return {
    -- ---------- Плагин добавления комментариев -----------
    { 'numToStr/Comment.nvim', opts = { }},

    -- - Автоматическая расстановка закрывающих спецсиволов -
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
}