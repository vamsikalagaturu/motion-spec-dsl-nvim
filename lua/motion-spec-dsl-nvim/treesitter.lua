local M = {}

local function plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
end

local function ensure_parser(root)
  local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
  local so = parser_dir .. "/robmot.so"
  local src = root .. "/src/parser.c"
  if vim.fn.filereadable(src) == 0 then
    return
  end
  local so_mtime = vim.fn.getftime(so)
  local src_mtime = vim.fn.getftime(src)
  if so_mtime >= src_mtime then
    return
  end

  vim.fn.mkdir(parser_dir, "p")
  local out = vim.fn.system(string.format(
    "gcc -O2 -shared -fPIC -o %s %s -I %s",
    vim.fn.shellescape(so),
    vim.fn.shellescape(src),
    vim.fn.shellescape(root .. "/src")
  ))
  if vim.v.shell_error ~= 0 then
    vim.notify("motion-spec-dsl-nvim: parser compilation failed:\n" .. out, vim.log.levels.WARN)
  end
end

function M.setup()
  local root = plugin_root()

  -- Ensure Neovim can find the queries/ directory regardless of plugin manager.
  local rtp = vim.opt.runtimepath:get()
  if not vim.tbl_contains(rtp, root) then
    vim.opt.runtimepath:append(root)
  end

  ensure_parser(root)

  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok then
    local configs = type(parsers.get_parser_configs) == "function"
      and parsers.get_parser_configs()
      or parsers
    configs.robmot = {
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
