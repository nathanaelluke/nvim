return {
    "aznhe21/actions-preview.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    event = "LspAttach",
    opts = {
        backend = { "telescope" },

        highlight_command = {
            function()
                return require("actions-preview.highlight").delta()
            end,
        },
    },
}
