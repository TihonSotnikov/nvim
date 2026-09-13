vim.keymap.set("n", "gl", function()
  require("config.hover").show()
end, { desc = "Diagnostics + Documentation" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>Y", '"+y$', { desc = "Yank to Clipboard (EOL)" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from Clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste from Clipboard (Before)" })

vim.keymap.set({ "n", "x", "o" }, "ж", ";", { remap = true, desc = "Repeat Find" })
vim.keymap.set({ "n", "x", "o" }, "б", ",", { remap = true, desc = "Repeat Find Reverse" })

local cmd_abbrev = {
  ["й"] = "q",
  ["Й"] = "q",
  ["ц"] = "w",
  ["Ц"] = "w",
  ["цй"] = "wq",
  ["Цй"] = "wq",
  ["ЦЙ"] = "wq",
  ["йф"] = "qa",
  ["Йф"] = "qa",
  ["ЙФ"] = "qa",
  ["я"] = "q!",
  ["Я"] = "q!",
}

for lhs, rhs in pairs(cmd_abbrev) do
  vim.keymap.set("ca", lhs, function()
    return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs and rhs or lhs
  end, { expr = true })
end

Snacks.toggle({
  name = "Completion",
  get = function()
    return require("config.completion").enabled(vim.bo.filetype)
  end,
  set = function(state)
    require("config.completion").set(vim.bo.filetype, state)
  end,
  notify = function(state)
    local ft = vim.bo.filetype
    Snacks.notify[state and "info" or "warn"](
      ("Completion **%s** for `%s`"):format(state and "enabled" or "disabled", ft == "" and "?" or ft),
      { title = "Completion" }
    )
  end,
}):map("<leader>uk")
