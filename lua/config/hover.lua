local M = {}

local icons = {
  [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
  [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
  [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
  [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
}

-- diagnostics are plain text, but the float renders them as markdown
local function escape_markdown(text)
  text = text:gsub("([\\`*_{}%[%]<>#~|&])", "\\%1")
  -- a continuation line must not turn into a list item
  text = text:gsub("\n(%s*)([-+])(%s)", "\n%1\\%2%3")
  return (text:gsub("\n(%s*)(%d+)([.)])(%s)", "\n%1%2\\%3%4"))
end

local function diagnostic_lines(buf, lnum)
  local lines = {}
  for _, d in ipairs(vim.diagnostic.get(buf, { lnum = lnum })) do
    local tag = d.source or ""
    if d.code then
      tag = tag == "" and tostring(d.code) or (tag .. ": " .. d.code)
    end
    local body = vim.split(escape_markdown(vim.trim(d.message)), "\n")
    body[1] = (icons[d.severity] or "") .. body[1]
    if tag ~= "" then
      body[#body] = body[#body] .. "  `" .. tag .. "`"
    end
    vim.list_extend(lines, body)
    lines[#lines + 1] = ""
  end
  if #lines > 0 then
    table.remove(lines)
  end
  return lines
end

local function render(lines)
  lines = vim.split(table.concat(lines, "\n"):gsub("\r", ""), "\n")
  while lines[#lines] == "" do
    table.remove(lines)
  end
  if #lines == 0 then
    return vim.notify("No information", vim.log.levels.INFO)
  end
  vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    focusable = true,
    focus_id = "gl",
    max_width = 90,
    max_height = 25,
    wrap = true,
  })
end

function M.show()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local diags = diagnostic_lines(buf, cursor[1] - 1)

  local method = "textDocument/hover"
  if #vim.lsp.get_clients({ bufnr = buf, method = method }) == 0 then
    return render(diags)
  end

  vim.lsp.buf_request_all(buf, method, function(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end, function(results)
    -- the cursor moved while the servers were answering: this popup is stale
    if vim.api.nvim_get_current_win() ~= win or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), cursor) then
      return
    end
    local doc = {}
    local ids = vim.tbl_keys(results)
    table.sort(ids)
    for _, id in ipairs(ids) do
      local res = results[id]
      local contents = res.result and res.result.contents
      if contents then
        local md = vim.lsp.util.convert_input_to_markdown_lines(contents)
        if vim.trim(table.concat(md, "")) ~= "" then
          if #doc > 0 then
            doc[#doc + 1] = "---"
          end
          vim.list_extend(doc, md)
        end
      end
    end
    local lines = diags
    if #doc > 0 then
      if #lines > 0 then
        lines[#lines + 1] = "---"
      end
      vim.list_extend(lines, doc)
    end
    render(lines)
  end)
end

return M
