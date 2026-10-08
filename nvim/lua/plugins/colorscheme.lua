return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local background = vim.o.background
        local theme
        if background == "light" then
          theme = "catppuccin-latte"
        else
          theme = "tokyonight-moon"
        end

        vim.cmd.colorscheme(theme)
      end,
    },
  },
}
