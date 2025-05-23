return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "jsonls",
          "pyright",
          "svelte",
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local servers = { "lua_ls", "jsonls", "pyright", "svelte" }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({})
      end
    end,
  },
}
