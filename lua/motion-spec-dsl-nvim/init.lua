local M = {}

---@class MotionSpecDslNvimConfig
---@field enable_lsp boolean Enable the language server (default: true)
---@field enable_treesitter boolean Register the tree-sitter parser (default: true)
---@field python string|nil Path to a python executable that has pygls installed
---@field lspconfig table|nil Extra options forwarded to lspconfig.motion_spec_ls.setup()

M.config = {
  enable_lsp = true,
  enable_treesitter = true,
  python = nil,
  lspconfig = {},
}

---@param opts MotionSpecDslNvimConfig|nil
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if M.config.enable_treesitter then
    require("motion-spec-dsl-nvim.treesitter").setup()
  end

  if M.config.enable_lsp then
    require("motion-spec-dsl-nvim.lsp").setup(M.config)
  end
end

return M
