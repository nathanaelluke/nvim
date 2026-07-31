require("config.options")
require("config.lazy")
require("config.keymaps")

local theme_file = vim.fn.stdpath("data") .. "/current_theme.txt"
local f = io.open(theme_file, "r")
local theme_to_load = "neomodern"

if f then
  local saved_theme = f:read("*l")
  f:close()
  if saved_theme and saved_theme ~= "" then
    theme_to_load = saved_theme
  end
end

pcall(vim.cmd.colorscheme, theme_to_load)
