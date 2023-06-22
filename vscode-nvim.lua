vim.g.mapleader = " "
vim.opt.clipboard:append("unnamedplus")

local function map(mode, lhs, rhs, opts)
	local options = opts or {}
	options.noremap = options.noremap == nil and true or options.noremap
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use("easymotion/vim-easymotion")
	use("tpope/vim-surround")
	use("ggandor/leap.nvim")
	use("ggandor/flit.nvim")
end)
require("leap").add_default_mappings()
require("flit").setup()

map("v", "J", ":move '>+1<CR>gv-gv", { nowait = true })
map("v", "K", ":move '<-2<CR>gv-gv", { nowait = true })

map("n", "o", "o<esc>")
map("n", "O", "O<esc>")
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("n", "G", "Gzz")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-A-l>", ":%s/<<C-r><C-w>>/<C-r><C-w>/gI<Left><Left><Left><CR>")

map("n", "<C-j>", "<C-w>j", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })
map("n", "<C-Up>", "<C-w>+", { silent = true })
map("n", "<C-Down>", "<C-w>-", { silent = true })
map("n", "<C-Left>", "<C-w>>", { silent = true })
map("n", "<C-Right>", "<C-w><", { silent = true })

map("n", "<M-Down>", "<cmd>t.<cr>", { nowait = true })
map("n", "<M-Up>", "<cmd>t -1<cr>", { nowait = true })
map("n", "<M-Down>", "<cmd>m+<cr>", { nowait = true })
map("n", "<M-Up>", "<cmd>m-2<cr>", { nowait = true })
