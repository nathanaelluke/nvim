local function close_oil()
    local original = vim.w.oil_original_buffer
    if
        not vim.w.is_oil_win
        and original == vim.w.oil_alpha_origin
        and original ~= nil
        and not vim.api.nvim_buf_is_valid(original)
    then
        require("alpha").start(false)
    else
        require("oil").close()
    end
end

return {
    "stevearc/oil.nvim",
    commit = "e89a8f8a",
    lazy = false,
    opts = {
        columns = {},
        keymaps = {
            ["q"] = {
                callback = close_oil,
                desc = "Close oil and restore original buffer",
            },
            ["<C-c>"] = {
                callback = close_oil,
                desc = "Close oil and restore original buffer",
            },
        },
        confirmation = {
            border = "single",
        },
    },
    config = function(_, opts)
        require("oil").setup(opts)
        vim.api.nvim_create_autocmd("BufLeave", {
            group = vim.api.nvim_create_augroup(
                "OilAlphaReturn",
                { clear = true }
            ),
            desc = "Remember the dashboard so Oil can recreate it on close",
            callback = function(event)
                if vim.bo[event.buf].filetype == "alpha" then
                    -- Let Alpha wipe its buffer and remove its window callbacks.
                    vim.w.oil_alpha_origin = event.buf
                end
            end,
        })
    end,
}
