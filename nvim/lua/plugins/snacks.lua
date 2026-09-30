return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = {
              layout = {
                width = 32,
                min_width = 32,
              },
            },
            hidden = true,
            ignored = true,
            follow_file = true,
          },
        },
      },
    },
  },
}
