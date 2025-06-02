" Essential Vim Plugins
" This file lists plugins to install with vim-plug

" Plugin list
call plug#begin('~/.vim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Git integration
Plug 'tpope/vim-fugitive'

call plug#end()

" Plugin configurations
" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
