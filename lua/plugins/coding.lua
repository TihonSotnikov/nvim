return {
  {
    "saghen/blink.cmp",
    opts = {
      signature = { enabled = false },
      keymap = { preset = "super-tab" },
      enabled = function()
        return require("config.completion").enabled(vim.bo.filetype)
      end,
    },
  },
}
