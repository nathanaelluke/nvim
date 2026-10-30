return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    cmd = "Yazi",
    opts = {
        config_home = require("config.yazi_theme").config_home(),
        open_for_directories = true,
        keymaps = false,
        floating_window_scaling_factor = 1,
        yazi_floating_window_border = "none",
        yazi_floating_window_zindex = 1001,
        hooks = {
            before_opening_window = function()
                require("config.yazi_theme").sync()
            end,
        },
    },
}
