let g:neovim = 1
set termguicolors

" Enable Mouse
set mouse=a

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
" nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
" inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
" vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv

source ~/.vim/common.vim

" Close file when closing last buffer
" https://vi.stackexchange.com/questions/37814/how-to-revert-to-close-file-when-buffer-closes-behavior-in-neovim
set nohidden

" Trailing double slash means uses full path in filename to stop clashes in a
" global location.
set directory=~/.vim/neo/swap//

" Use a persistent undo file instead
set undodir=~/.vim/neo/undo//
