# motion-spec-dsl-nvim

Neovim plugin for the `motion-spec-dsl` TextX guarded motion DSL (`.rob_mot` files).

Provides:
- Syntax highlighting via tree-sitter (with Vim regex fallback)
- LSP diagnostics from the bundled textX grammar
- Hover documentation for DSL keywords and solver/controller constructs
- Completion items and snippets for imports, common blocks, monitors, controllers, solvers, routing phrases, and units
- Compact DSL unit validation (`rad/s`, `m/s`, `m/s2`, `Nm`, etc.)

## Requirements

- Neovim >= 0.10 (0.11+ recommended for native `vim.lsp.config`)
- Python 3.10+
- `nvim-treesitter` (optional, for tree-sitter highlighting)

Python dependencies (`pygls`, `textX`) are installed automatically into a plugin-local virtualenv on first use.

## Installation

### lazy.nvim / LazyVim

```lua
{
  "vamsikalagaturu/motion-spec-dsl-nvim",
  ft = "rob_mot",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    vim.filetype.add({ extension = { rob_mot = "rob_mot" } })
  end,
  config = function()
    require("motion-spec-dsl-nvim").setup()
  end,
}
```

Run `:TSInstall motion_spec` once to compile the tree-sitter parser.

The `init` hook is recommended when lazy-loading on `ft = "rob_mot"` so Neovim
knows the filetype before Lazy decides whether to load the plugin.

## Configuration

```lua
require("motion-spec-dsl-nvim").setup({
  python = nil,
  enable_treesitter = true,
  enable_lsp = true,
  lspconfig = {},
})
```

## Syntax highlighting

Highlighted constructs include:
- block keywords such as `MOTION_SPEC`, `CONSTRAINT_HANDLER`, `CONTEXT`, `WHEN`, `WHILE`, `UNTIL`
- controller and solver keywords such as `MONITORS`, `CONTROLLERS`, `PRIORITIES`, `SOLVER`
- namespace declarations and lookups (`ns`, `World[...]`, `Spec[...]`, `Post[...]`, `Pre[...]`)
- imports (`import "common.rob_mot"`)
- quantity and type names
- strings, numbers, units, and comments

## LSP Features

The bundled Python LSP starts automatically for `rob_mot` buffers after setup.
It uses the same textX grammar as the DSL package.

Diagnostics:
- parse errors for invalid DSL syntax
- import resolution through textX `FQNImportURI` for `import "file.rob_mot"`
- compact-unit errors when verbose QUDT-style units such as `M-PER-SEC` are used
- section/keyword errors from the grammar

Hover:
- block signatures such as `MOTION_SPEC (ns=<namespace>) <name> { ... }`
- import syntax for reusing `.rob_mot` files
- section descriptions for `CONTEXT`, `WHEN`, `WHILE`, `UNTIL`, `SOLVER`, etc.
- controller, monitor, and solver construct descriptions

Completion:
- `import "common.rob_mot"` snippet
- `MOTION_SPEC` and `CONSTRAINT_HANDLER` block snippets
- monitor snippets:
  - `monitor <constraint> and trigger event <event> when active`
  - `monitor <constraint> and set flag <flag> while active`
- PID controller and controller-routing snippets
- base solver snippets for `VelocityCompositionSolver` and `ForceDistributionSolver`
- compact unit completions: `rad/s`, `m/s`, `m/s2`, `Nm`, `rad`, `N`, etc.

In LazyVim, use the normal LSP bindings:
- `K` for hover
- insert-mode completion through your configured completion UI
- `:LspInfo` to confirm `motion_spec_ls` is attached

## License

MIT
