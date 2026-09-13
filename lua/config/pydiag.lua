local M = {}

local cache = {}
local applying = false

local function covered(buf)
  local names = vim.diagnostic.get_namespaces()
  local lines = {}
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    local ns = names[d.namespace]
    if ns and ns.name:find("pyright", 1, true) then
      lines[d.lnum] = true
    end
  end
  return lines
end

local function signature(skip)
  local keys = vim.tbl_keys(skip)
  table.sort(keys)
  return table.concat(keys, ",")
end

local function push(buf, force)
  local entry = cache[buf]
  if not entry or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local skip = covered(buf)
  local sig = signature(skip)
  if not force and entry.sig == sig then
    return
  end
  entry.sig = sig

  local result = vim.tbl_extend("force", {}, entry.result)
  local field = result.items and "items" or "diagnostics"
  local kept = {}
  for _, item in ipairs(entry.result[field] or {}) do
    if not skip[item.range.start.line] then
      kept[#kept + 1] = item
    end
  end
  result[field] = kept

  applying = true
  local ok, err = pcall(vim.lsp.handlers[entry.method], entry.err, result, entry.ctx, entry.config)
  applying = false
  if not ok then
    vim.notify("pydiag: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local function capture(method)
  return function(err, result, ctx, config)
    local buf = ctx.bufnr
    if not buf and ctx.params and ctx.params.textDocument then
      buf = vim.uri_to_bufnr(ctx.params.textDocument.uri)
    end
    if not buf or not result or not (result.items or result.diagnostics) then
      return vim.lsp.handlers[method](err, result, ctx, config)
    end
    cache[buf] = {
      method = method,
      err = err,
      result = vim.deepcopy(result),
      ctx = ctx,
      config = config,
    }
    return push(buf, true)
  end
end

M.handlers = {
  ["textDocument/diagnostic"] = capture("textDocument/diagnostic"),
  ["textDocument/publishDiagnostics"] = capture("textDocument/publishDiagnostics"),
}

function M.setup()
  local group = vim.api.nvim_create_augroup("pydiag", { clear = true })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function(args)
      if not applying and cache[args.buf] then
        push(args.buf, false)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      cache[args.buf] = nil
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "ruff" then
        cache[args.buf] = nil
      end
    end,
  })
end

return M
