" Common Settings
set nocompatible
filetype on
filetype plugin on
filetype indent on
syntax on
set number
set relativenumber
set cursorline
set cursorcolumn
set shiftwidth=4
set tabstop=4
set expandtab
set nobackup
set scrolloff=8
set incsearch
set ignorecase
set smartcase
set showcmd
set showmode
set showmatch
set hlsearch
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set clipboard=unnamedplus

" Mappings 
let mapleader = ' '
inoremap jj <Esc>
inoremap jk <Esc>
nnoremap o o<esc>
nnoremap O O<esc>
nnoremap n nzz
nnoremap N Nzz
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
noremap <c-up> <c-w>+
noremap <c-down> <c-w>-
noremap <c-left> <c-w>>
noremap <c-right> <c-w><

" Color Scheme
colorscheme molokai

" Plugins 
call plug#begin('~/.vim/plugged')
    Plug 'mg979/vim-visual-multi', {'branch': 'master'}
    Plug 'valloric/youcompleteme'
    Plug 'ervandew/supertab'
    Plug 'majutsushi/tagbar'
    Plug 'tpope/vim-surround'
    Plug 'dense-analysis/ale'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
call plug#end()

" Plugin settings
let g:airline_theme='tomorrow'
let g:tagbar_ctags_bin='/usr/bin/ctags'
let g:ycm_autoclose_preview_window_after_completion = 1
set previewpopup=height:10,width:60,highlight:PMenuSbar
set completeopt+=popup
set completepopup=height:15,width:60,border:off,highlight:PMenuSbar
nnoremap <F3> :NERDTreeToggle<cr>
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']
nmap <F8> :TagbarToggle<CR>
nmap S <Plug>YSsurround
