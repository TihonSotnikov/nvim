-- pyright only looks at `python` from PATH, so it can't see an unactivated .venv (uv run never activates it)
local function project_python(root)
  if vim.env.VIRTUAL_ENV then
    return nil
  end
  local venv = vim.fs.find(".venv", { upward = true, path = root, type = "directory", stop = vim.uv.os_homedir() })[1]
  local python = venv and venv .. "/bin/python"
  return python and vim.fn.executable(python) == 1 and python or nil
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = project_python(config.root_dir or vim.fn.getcwd())
          end,
        },
        ruff = {
          mason = false,
          on_init = function(client)
            client.server_capabilities.hoverProvider = false
          end,
          init_options = {
            settings = {
              -- ruff's INFO chatter goes to stderr, which nvim logs as ERROR and buries real problems in lsp.log
              logLevel = "warn",
              -- pyright reports these too, so ruff stays quiet about them
              showSyntaxErrors = false,
              lint = {
                ignore = {
                  "F631", -- reportAssertAlwaysTrue
                  "F701", -- "break" outside loop
                  "F704", -- "yield" outside function
                  "F706", -- "return" outside function
                  "F821", -- reportUndefinedVariable
                  "F822", -- reportUnsupportedDunderAll
                },
              },
            },
          },
        },
      },
    },
  },
}
