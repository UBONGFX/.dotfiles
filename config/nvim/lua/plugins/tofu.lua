return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        terraform_fmt = {
          command = "tofu",
          args = { "fmt", "-no-color", "-" },
        },
      },
    },
  },
}
