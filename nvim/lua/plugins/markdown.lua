return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = function()
      return {
        preset = "obsidian",

        pipe_table = {
          preset = "round",
        },

        heading = {
          backgrounds = {},
        },

        code = {
          disable_background = true,
          border = "none",
          language_border = " ",
          highlight_border = false,
        },
      }
    end,
  },
  {
    "stevearc/aerial.nvim",
    keys = {
      {
        "<leader>mo",
        "<cmd>AerialToggle<cr>",
        desc = "Markdown Outline",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  }
}
