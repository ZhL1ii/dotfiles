return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
      },

      completion = {
        menu = {
          border = "rounded",
          max_height = 12,
          scrollbar = true,
        },

        ghost_text = {
          enabled = false,
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            max_width = 70,
            max_height = 20,
            scrollbar = true,
          },
        },
      },

      signature = {
        window = {
          border = "rounded",
        },
      },
    },
  },
}
