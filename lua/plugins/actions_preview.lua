return {
    "aznhe21/actions-preview.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    event = "LspAttach",
    opts = {
        backend = { "telescope" },

        telescope = {
            layout_strategy = "vertical",
            layout_config = {
                height = 0.75,
                prompt_position = "top",
                preview_cutoff = 40,
            },
            borderchars = {
                "─",
                "│",
                "─",
                "│",
                "┌",
                "┐",
                "┘",
                "└",
            },
        },

        highlight_command = {
            function()
                return require("actions-preview.highlight").delta()
            end,
        },
    },
}
