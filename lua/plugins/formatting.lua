-- clangd's --fallback-style only accepts predefined styles (llvm is 2 spaces), so C/C++ are formatted with clang-format
-- directly: a project's .clang-format wins, otherwise LLVM style with 4 spaces.
local fallback_style = "{BasedOnStyle: LLVM, IndentWidth: 4}"

local function style(ctx)
  local found = vim.fs.find({ ".clang-format", "_clang-format" }, { upward = true, path = ctx.dirname })[1]
  return "-style=" .. (found and "file" or fallback_style)
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      formatters = {
        ["clang-format"] = {
          command = require("config.llvm").bin("clang-format"),
          args = function(_, ctx)
            return { "-assume-filename", ctx.filename, style(ctx) }
          end,
          range_args = function(_, ctx)
            local util = require("conform.util")
            local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
            return {
              "-assume-filename",
              ctx.filename,
              style(ctx),
              "--offset",
              tostring(start_offset),
              "--length",
              tostring(end_offset - start_offset),
            }
          end,
        },
      },
    },
  },
}
