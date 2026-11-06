return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "dark",
      },
      on_highlights = function(hl, c)
        hl.StatusLine.bg = "none"
        hl.StatusLineNC.bg = "none"
        hl.FloatBorder = { bg = c.bg_dark, fg = c.border_highlight }
        hl.CursorLine = { bg = "none" }
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl["@markup.raw.markdown_inline"] = { fg = c.blue }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
