-- places where a snippet is never what you want (it would only be noise next to the real completion)
local no_snippets_in = {
  comment = true,
  line_comment = true,
  block_comment = true,
  string = true,
  string_content = true,
  string_literal = true,
  raw_string_literal = true,
  char_literal = true,
  parameters = true,
  lambda_parameters = true,
  type_parameters = true,
  parameter_list = true,
}

local function snippets_allowed(ctx)
  local before = ctx.bounds.line:sub(1, ctx.bounds.start_col - 1)
  if before:match("%.$") or before:match("%->$") or before:match("::$") then
    return false
  end
  local ok, node = pcall(vim.treesitter.get_node, { pos = { ctx.cursor[1] - 1, math.max(ctx.cursor[2] - 1, 0) } })
  while ok and node do
    if no_snippets_in[node:type()] then
      return false
    end
    node = node:parent()
  end
  return true
end

return {
  {
    "saghen/blink.cmp",
    opts = {
      signature = { enabled = false },
      keymap = { preset = "super-tab" },
      enabled = function()
        return require("config.completion").enabled(vim.bo.filetype)
      end,
      sources = {
        providers = {
          snippets = { should_show_items = snippets_allowed },
          buffer = {
            -- buffer words are noise next to an LSP: they fill the menu whenever the server has nothing to offer.
            -- The command line (/ search) has no LSP, so it keeps them.
            enabled = function()
              if vim.api.nvim_get_mode().mode:sub(1, 1) == "c" then
                return true
              end
              return #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" }) == 0
            end,
          },
        },
      },
    },
  },
}
