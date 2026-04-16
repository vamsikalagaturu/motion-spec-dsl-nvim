local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

function M.setup()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    local root = plugin_root()
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
      filetype = "rob_mot",
      maintainers = {},
    }
  end
end

return M
