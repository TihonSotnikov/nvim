vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_spell_in_scratch", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "plaintex", "typst" },
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      vim.opt_local.spell = false
    end
  end,
})
