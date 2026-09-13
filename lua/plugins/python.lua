return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local pydiag = require("config.pydiag")
      pydiag.setup()
      opts.servers = opts.servers or {}
      opts.servers.pyright = opts.servers.pyright or {}
      opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, {
        mason = false,
        handlers = pydiag.handlers,
      })
    end,
  },
}
