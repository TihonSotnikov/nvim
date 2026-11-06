vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_source", { clear = true }),
  pattern = "markdown",
  callback = function(ev)
    -- real files only: LSP popups are markdown too and need conceal
    if vim.bo[ev.buf].buftype == "" then
      vim.opt_local.conceallevel = 0
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_spell_in_scratch", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "plaintex", "typst" },
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      vim.opt_local.spell = false
    end
  end,
})
