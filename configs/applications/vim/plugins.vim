" Essential Vim Plugins
" This file lists plugins to install with vim-plug

" Install vim-plug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

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
