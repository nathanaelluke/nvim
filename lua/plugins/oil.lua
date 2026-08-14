return {
    "stevearc/oil.nvim",
    commit = "e89a8f8a",
    event = "VeryLazy",
    cmd = "Oil",
    opts = {
        columns = {
            -- "icons",
            -- "permissions",
            -- "size",
            -- "mtime"
        },
        keymaps = {
            ["q"] = "actions.close",
        },
        confirmation = {
            border = "single",
        },
    },
}
