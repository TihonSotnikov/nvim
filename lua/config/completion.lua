local M = {}

local path = vim.fn.stdpath("data") .. "/completion-filetypes.json"
local state

local function load()
  if state then
    return state
  end
  state = {}
  local fd = io.open(path, "r")
  if fd then
    local raw = fd:read("*a")
    fd:close()
    local ok, decoded = pcall(vim.json.decode, raw)
    if ok and type(decoded) == "table" then
      for _, ft in ipairs(decoded) do
        if type(ft) == "string" then
          state[ft] = true
        end
      end
    end
  end
  return state
end

local function save()
  local list = vim.tbl_keys(load())
  table.sort(list)
  local fd = io.open(path, "w")
  if not fd then
    return vim.notify("Cannot write " .. path, vim.log.levels.ERROR)
  end
  fd:write(vim.json.encode(list))
  fd:close()
end

function M.enabled(ft)
  ft = ft or vim.bo.filetype
  return ft ~= "" and load()[ft] == true
end

function M.set(ft, value)
  ft = ft or vim.bo.filetype
  if ft == "" then
    return
  end
  load()[ft] = value or nil
  save()
end

return M
