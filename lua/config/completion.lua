local M = {}

-- Filetypes with completion switched on. The file is shared by every running nvim, so it is re-read before each
-- change (never overwrite another instance's choice) and polled for outside changes at most once a second.
local path = vim.fn.stdpath("data") .. "/completion-filetypes.json"
local state, stamp
local checked = -math.huge

local function mtime()
  local st = vim.uv.fs_stat(path)
  return st and (st.mtime.sec .. ":" .. st.mtime.nsec) or ""
end

local function read()
  local set = {}
  local fd = io.open(path, "r")
  if fd then
    local raw = fd:read("*a")
    fd:close()
    local ok, decoded = pcall(vim.json.decode, raw)
    if ok and type(decoded) == "table" then
      for _, ft in ipairs(decoded) do
        if type(ft) == "string" then
          set[ft] = true
        end
      end
    end
  end
  return set
end

local function load()
  local now = vim.uv.now()
  if state and now - checked < 1000 then
    return state
  end
  checked = now
  local current = mtime()
  if not state or current ~= stamp then
    state, stamp = read(), current
  end
  return state
end

local function save()
  local list = vim.tbl_keys(state)
  table.sort(list)
  local tmp = path .. "." .. vim.uv.os_getpid() .. ".tmp"
  local fd = io.open(tmp, "w")
  if not fd then
    return vim.notify("Cannot write " .. path, vim.log.levels.ERROR)
  end
  fd:write(vim.json.encode(list))
  fd:close()
  local ok, err = vim.uv.fs_rename(tmp, path)
  if not ok then
    os.remove(tmp)
    return vim.notify("Cannot write " .. path .. ": " .. tostring(err), vim.log.levels.ERROR)
  end
  stamp = mtime()
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
  checked = -math.huge
  load()[ft] = value or nil
  save()
end

return M
