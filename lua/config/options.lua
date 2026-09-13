vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.autoformat = false

vim.opt.clipboard = ""
vim.opt.guicursor = "a:block-blinkon0"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.spelllang = { "en", "ru" }

vim.o.langmap = table.concat({
  [==[ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ]==],
  [==[фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz]==],
  [==[ЁХЪЖЭБЮ№;~{}:\"<>#]==],
  [==[ёхъэю;`[]'.]==],
}, ",")
