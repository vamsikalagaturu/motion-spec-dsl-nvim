local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

local function ensure_venv(root, on_done)
  local venv_py = root .. "/.venv/bin/python3"
  if vim.fn.executable(venv_py) == 1 then
    on_done(true)
    return
  end

  local build_sh = root .. "/build.sh"
  if vim.fn.filereadable(build_sh) == 0 then
    on_done(false)
    return
  end

  vim.notify("motion-spec-dsl-nvim: installing server dependencies...", vim.log.levels.INFO)
  vim.fn.jobstart({ "bash", build_sh }, {
    cwd = root,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("motion-spec-dsl-nvim: server ready.", vim.log.levels.INFO)
        on_done(true)
      else
        vim.notify("motion-spec-dsl-nvim: build.sh failed (exit " .. code .. ")", vim.log.levels.ERROR)
        on_done(false)
      end
    end,
  })
end

local function find_python(root, hint)
  local candidates = {}
  if hint then
    table.insert(candidates, hint)
  end
  table.insert(candidates, root .. "/.venv/bin/python3")
  table.insert(candidates, "python3")
  table.insert(candidates, "python")

  for _, cmd in ipairs(candidates) do
    if vim.fn.executable(cmd) == 1 then
      vim.fn.system({ cmd, "-c", "import pygls.lsp.server" })
      if vim.v.shell_error == 0 then
        return cmd
      end
    end
  end
  return nil
end

local function register_server(root, opts)
  local server_script = root .. "/server/motion_spec_lsp.py"
  if vim.fn.filereadable(server_script) == 0 then
    vim.notify("motion-spec-dsl-nvim: server script not found: " .. server_script, vim.log.levels.ERROR)
    return
  end

  local python = find_python(root, opts.python)
  if not python then
    vim.notify("motion-spec-dsl-nvim: no python with pygls found; LSP unavailable.", vim.log.levels.WARN)
    return
  end

  local server_opts = {
    cmd = { python, server_script },
    filetypes = { "robmot" },
    root_markers = { ".git" },
    settings = {},
  }

  if vim.lsp.config then
    vim.lsp.config("motion_spec_ls", server_opts)
    vim.lsp.enable("motion_spec_ls")
    return
  end

  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    local configs = require("lspconfig.configs")
    if not configs.motion_spec_ls then
      configs.motion_spec_ls = {
        default_config = vim.tbl_extend("force", server_opts, {
          name = "motion_spec_ls",
          docs = {
            description = "Language server for the motion-spec-dsl TextX DSL (.robmot files)",
          },
        }),
      }
    end
    lspconfig.motion_spec_ls.setup(opts.lspconfig or {})
    return
  end

  vim.notify(
    "motion-spec-dsl-nvim: Neovim >= 0.11 or nvim-lspconfig is required for LSP.",
    vim.log.levels.WARN
  )
end

function M.setup(opts)
  opts = opts or {}
  local root = plugin_root()
  ensure_venv(root, function(ok)
    if ok then
      register_server(root, opts)
    end
  end)
end

return M
