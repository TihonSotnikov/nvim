local M = {}

local prefix = "/opt/homebrew/opt/llvm/bin/"

--- Homebrew LLVM tool if installed (Xcode's clangd/clang-format in PATH are older), otherwise the one from PATH.
---@param name string
---@return string
function M.bin(name)
  return vim.fn.executable(prefix .. name) == 1 and prefix .. name or name
end

return M
