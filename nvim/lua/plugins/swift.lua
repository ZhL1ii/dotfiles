return {
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- 声明式安装 swift treesitter
      ensure_installed = {
        "swift",
      },
    },
  },

  -- lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {},
      },
    },
  },

  -- xcodebuild
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
    },

    keys = {
      {
        "<leader>Xb",
        "<cmd>XcodebuildBuild<cr>",
        desc = "Build Project",
      },
      {
        "<leader>Xr",
        "<cmd>XcodebuildBuildRun<cr>",
        desc = "Build & Run Project",
      },
      {
        "<leader>Xt",
        "<cmd>XcodebuildTest<cr>",
        desc = "Run Tests",
      },
      {
        "<leader>Xl",
        "<cmd>XcodebuildToggleLogs<cr>",
        desc = "Toggle Xcodebuild Logs",
      },
      {
        "<leader>Xa",
        "<cmd>XcodebuildPicker<cr>",
        desc = "Xcodebuild Actions",
      },

      -- debug
      {
        "<leader>Xd",
        function()
          require("xcodebuild.integrations.dap").build_and_debug()
        end,
        desc = "Build & Debug",
      },
      {
        "<leader>XD",
        function()
          require("xcodebuild.integrations.dap").debug_without_build()
        end,
        desc = "Debug Without Building",
      },
      {
        "<leader>XT",
        function()
          require("xcodebuild.integrations.dap").debug_tests()
        end,
        desc = "Debug Tests",
      },
    },

    opts = {
      integrations = {
        -- 指定 picker 为 snacks
        telescope_nvim = {
          enabled = false,
        },
        fzf_lua = {
          enabled = false,
        },
        snacks_nvim = {
          enabled = true,
        },
        xcode_build_server = {
          enabled = true,
          guess_scheme = false,
        },
      },
    },

    config = function(_, opts)
      require("xcodebuild").setup(opts)
      require("xcodebuild.integrations.dap").setup()
    end,
  },

  -- formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swift" },
      },
    },
  },

  -- lint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
}
