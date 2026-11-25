return {
    "techwizrd/render-latex.nvim",
    ft = "markdown",

    opts = {
        conceal = true,

        render = {
            preset = "match_text",
            match_text_size = true,
            text_scale = 0.5,

            scale = 1.5,

            padding = 4,

            equation_labels = "right",
            equation_label_format = "(%d)",

            inline = "conceal",
            inline_symbols = true,

            live_preview = true,
            hide_on_cmdline = false,

            background = "transparent",
        },

        image = {
            backend = "kitty",

            -- These should correspond to your Kitty character-cell size.
            -- Keep your existing values for now.
            cell_width_px = 22,
            cell_height_px = 50,
        },
    },

    config = function(_, opts)
        -- render-latex uses conceal extmarks to hide the source equation.
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = "nc"

        local latex = require("render_latex")

        latex.setup(opts)

        -- Keep your custom centered-equation behavior.
        latex.register_source({
            name = "markdown-centered",
            incremental = true,
            inline = true,

            attach = function(bufnr)
                return vim.bo[bufnr].filetype == "markdown"
            end,

            display_equations = function(bufnr)
                return require("render_latex.detect").scan(bufnr)
            end,

            image_bounds = function(_, _, window, position)
                return {
                    start_col = position.col,
                    width = math.min(window.width, 80),
                }
            end,
        })
    end,
}
