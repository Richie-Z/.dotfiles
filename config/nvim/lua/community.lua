---@type LazySpec
local spec = {
  "AstroNvim/astrocommunity",
  -- UI
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.color.tint-nvim" },
  { import = "astrocommunity.recipes.telescope-lsp-mappings" },

  -- LSP
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  { import = "astrocommunity.lsp.actions-preview-nvim" },

  -- Git
  { import = "astrocommunity.git.blame-nvim" },

  -- Completion

  -- Icons
  { import = "astrocommunity/icon/mini-icons" },

  -- Plugins
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.indent.mini-indentscope" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.terminal-integration.vim-tmux-navigator" },
  { import = "astrocommunity.file-explorer.telescope-file-browser-nvim" },

  -- Motions
  { import = "astrocommunity.motion.flit-nvim" },
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.motion.mini-move" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.motion.marks-nvim" },

  -- Packs
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
}

return spec
