return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "jsonls",
        "pyright",
        "svelte",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {},
        lua_ls = {},
        pyright = {},
        svelte = {},
      },
    },
  },
}
