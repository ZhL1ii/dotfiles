return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        golangcilint = {
          cwd = function()
            return vim.fs.root(0, { "go.work", "go.mod" })
          end,
        },
      },
    },
  },
}
