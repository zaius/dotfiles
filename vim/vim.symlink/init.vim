let g:neovim = 1
"let g:black_virtualenv = "~/.config/nvim/black"
let g:black_skip_string_normalization = 0
set termguicolors

" Enable Mouse
set mouse=a

let g:black_virtualenv = "~/.vim/black-latest"

" Set Editor Font
if exists(':GuiFont')
    " Use GuiFont! to ignore font errors
    GuiFont Fira\ Code:h16
endif

" Disable GUI Tabline
if exists(':GuiTabline')
    GuiTabline 0
endif

" Right Click Context Menu (Copy-Cut-Paste)
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv

let g:neovim = 1

source ~/.vim/common.vim

" Trailing double slash means uses full path in filename to stop clashes in a
" global location.
set directory=~/.vim/neo/swap//

" Use a persistent undo file instead
set undodir=~/.vim/neo/undo//
