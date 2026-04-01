return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  cmd = "Yazi",
  opts = {
    open_for_directories = false,
    keymaps = false,
    set_keymappings_function = function(yazi_buffer_id, _, _)
      local function close_yazi()
        local win = vim.fn.bufwinid(yazi_buffer_id)
        if win ~= -1 then
          vim.api.nvim_win_close(win, true)
        end
      end

      vim.keymap.set({ "n", "t" }, "<Esc>", close_yazi, {
        buffer = yazi_buffer_id,
        nowait = true,
        silent = true,
        desc = "Close Yazi",
      })
    end,
    yazi_floating_window_border = "single",
  },
}
