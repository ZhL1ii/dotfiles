return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      -- 查看整个工作区的 diagnostics，适合快速定位项目里的错误和警告。
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Workspace diagnostics" },

      -- 只查看当前 buffer 的 diagnostics，适合聚焦当前文件。
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: Buffer diagnostics" },

      -- 查看 LSP references，比原生 quickfix 列表更直观。
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", desc = "Trouble: LSP references" },

      -- 查看 quickfix 列表，方便接管搜索结果或编译错误列表。
      { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", desc = "Trouble: Quickfix list" },

      -- 查看 location list，和现有的 vim.diagnostic.setloclist 配合使用。
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location list" },
    },
    opts = {
      -- 保持默认 UI 行为，只打开常用的可视化增强入口。
      -- 这样不会改变 diagnostics 的来源，也不会影响 LSP 本身。
    },
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      -- fidget 只负责显示 LSP 后台进度，例如初始化、索引和诊断刷新。
      -- 使用默认样式，减少和现有 UI 配置的耦合。
    },
  },
}
