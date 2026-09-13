return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.lsp.log.set_level(vim.log.levels.OFF)
      return vim.tbl_deep_extend("force", opts, {
        inlay_hints = { enabled = false },
        diagnostics = {
          virtual_text = false,
          float = { border = "rounded", source = true },
        },
        servers = {
          clangd = {
            mason = false,
            cmd = {
              "/opt/homebrew/opt/llvm/bin/clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders=0",
              "--fallback-style=llvm",
            },
          },
        },
      })
    end,
  },
}
