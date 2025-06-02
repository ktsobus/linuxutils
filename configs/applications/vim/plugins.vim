" Essential Vim Plugins
" This file lists plugins to install with vim-plug

" Plugin list
call plug#begin('~/.vim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Git integration
Plug 'tpope/vim-fugitive'

" Statuss line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Syntax checking
Plug 'scrooloose/syntastic'

" Autocomplete
Plug 'neoclide/coc.nvim'

call plug#end()

" Plugin configurations
" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
