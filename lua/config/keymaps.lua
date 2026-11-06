vim.keymap.set("n", "gl", function()
  require("config.hover").show()
end, { desc = "Diagnostics + Documentation" })

vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>Y", '"+y$', { desc = "Yank to Clipboard (EOL)" })
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from Clipboard" })
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste from Clipboard (Before)" })

-- langmap only translates keys into native commands, but flash.nvim replaces f/F/t/T/;/, and s/S/r/R with mappings,
-- and mappings are looked up before langmap. Map the Cyrillic keys explicitly so both layouts behave the same.
local cyrillic_keys = {
  { "ж", ";", { "n", "x", "o" }, "Repeat Find" },
  { "б", ",", { "n", "x", "o" }, "Repeat Find Reverse" },
  { "а", "f", { "n", "x", "o" }, "Find" },
  { "А", "F", { "n", "x", "o" }, "Find Backward" },
  { "е", "t", { "n", "x", "o" }, "Till" },
  { "Е", "T", { "n", "x", "o" }, "Till Backward" },
  { "ы", "s", { "n", "x", "o" }, "Flash" },
  { "Ы", "S", { "n", "x", "o" }, "Flash Treesitter" },
  { "к", "r", { "o" }, "Remote Flash" },
  { "К", "R", { "o", "x" }, "Treesitter Search" },
}
for _, key in ipairs(cyrillic_keys) do
  vim.keymap.set(key[3], key[1], key[2], { remap = true, desc = key[4] })
end

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
    if ft == "" then
      return Snacks.notify.warn("Buffer has no filetype, nothing to toggle", { title = "Completion" })
    end
    Snacks.notify[state and "info" or "warn"](
      ("Completion **%s** for `%s`"):format(state and "enabled" or "disabled", ft),
      { title = "Completion" }
    )
  end,
}):map("<leader>uk")
