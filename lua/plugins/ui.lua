return {
  {
    "folke/snacks.nvim",
    opts = {
      indent = { enabled = false },
    },
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.lsp = vim.tbl_deep_extend("force", opts.lsp or {}, {
        signature = { enabled = false },
        progress = { enabled = false },
      })
      opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
        cmdline_output = { format = "notify" },
      })
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        view = "cmdline_output",
        filter = { event = "msg_show", cmdline = "^:%s*!" },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons.git

      opts.sections.lualine_c = {
        LazyVim.lualine.root_dir(),
        "diagnostics",
        { "filename", path = 0 },
      }

      opts.sections.lualine_x = {
        {
          function()
            return require("noice").api.status.command.get()
          end,
          cond = function()
            return package.loaded["noice"] and require("noice").api.status.command.has()
          end,
          color = function()
            return { fg = Snacks.util.color("Statement") }
          end,
        },
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = function()
            return { fg = Snacks.util.color("Special") }
          end,
        },
        {
          "diff",
          symbols = { added = icons.added, modified = icons.modified, removed = icons.removed },
          source = function()
            local gs = vim.b.gitsigns_status_dict
            if gs then
              return { added = gs.added, modified = gs.changed, removed = gs.removed }
            end
          end,
        },
      }

      opts.sections.lualine_y = {
        { "location", padding = { left = 1, right = 1 } },
      }
      opts.sections.lualine_z = {}
    end,
  },
}
