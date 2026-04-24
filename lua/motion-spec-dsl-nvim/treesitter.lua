local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

function M.setup()
  local root = plugin_root()

  -- Ensure Neovim can find the queries/ directory regardless of plugin manager.
  local rtp = vim.opt.runtimepath:get()
  if not vim.tbl_contains(rtp, root) then
    vim.opt.runtimepath:append(root)
  end

  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    local configs = type(parsers.get_parser_configs) == "function"
      and parsers.get_parser_configs()
      or parsers
    configs.motion_spec = {
      install_info = {
        url = root,
        files = { "src/parser.c" },
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
      },
      filetype = "robmot",
      maintainers = {},
    }
  end
end

return M
