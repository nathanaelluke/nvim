return {
    "techwizrd/render-latex.nvim",
    ft = "markdown",

    opts = {
        render = {
            preset = "compact",
            match_text_size = true,
            text_scale = 0.85,
            scale = 1.25,
            padding = 0,

            equation_labels = "right",
            equation_label_format = "(%d)",
        },
        image = {
            backend = "kitty",
            cell_width_px = 22,
            cell_height_px = 50,
        },
    },

    config = function(_, opts)
        local latex = require("render_latex")

        local reference_width = 113
        local reference_scale = 0.85
        local min_scale = 0.40
        local max_scale = 1.10

        local function calculate_scale()
            local width = vim.api.nvim_win_get_width(0)

            local scale = reference_scale * (reference_width / width)

            scale = math.max(min_scale, math.min(max_scale, scale))

            return math.floor(scale * 100 + 0.5) / 100
        end

        opts.render.text_scale = calculate_scale()
        latex.setup(opts)

        local kitty = require("render_latex.image_backends.kitty")
        local original_set = kitty.set

        kitty.set = function(data, placement)
            local image_opts = vim.tbl_extend("force", {}, placement or {})

            image_opts.width = nil
            image_opts.height = nil

            return original_set(data, image_opts)
        end

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

        local group = vim.api.nvim_create_augroup(
            "render-latex-responsive",
            { clear = true }
        )

        local function update_size()
            if vim.bo.filetype ~= "markdown" then
                return
            end

            local config = require("render_latex.config")
            local new_scale = calculate_scale()

            if config.render.text_scale == new_scale then
                return
            end

            config.render.text_scale = new_scale

            require("render_latex.renderer").queue(
                vim.api.nvim_get_current_buf()
            )
        end

        vim.api.nvim_create_autocmd({
            "VimResized",
            "WinResized",
            "WinEnter",
        }, {
            group = group,
            callback = update_size,
        })
    end,
}
