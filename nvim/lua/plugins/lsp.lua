return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },

      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                ST1000 = false,
                ST1020 = false,
                ST1021 = false,
                ST1022 = false,
              },
            },
          },
        },
      },
    },
  },
}
