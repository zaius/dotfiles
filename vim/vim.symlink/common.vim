" See: https://github.com/junegunn/vim-plug/wiki/faq#automatic-installation
if empty(glob('~/.vim/plugged'))
  autocmd VimEnter * PlugInstall
endif

let g:ale_use_global_executables = 1
let pip_base = '/Users/zaius/Library/Python/3.9/bin'
let g:ale_python_pylint_executable = pip_base . '/pylint'
let g:ale_python_pylsp_executable = pip_base . '/pylsp'
let g:ale_python_flake8_executable = pip_base . '/flake8'

let g:ale_python_pylint_options = '--rcfile /Users/zaius/code/beyond/server/.pylintrc'

let g:ale_sql_pgformatter_options = '--spaces 2 --wrap-limit 88'
" let g:ale_python_pylint_use_global = 0
" \ 'php': ['prettier'],

let g:ale_sql_sqlformat_executable = 'cockroach'
let g:ale_sql_sqlformat_options = 'sqlfmt'


let g:ale_typescript_tsserver_executable = '/opt/homebrew/bin/tsserver'


" \ 'javascript': ['prettier', 'eslint'],
let g:ale_fixers = {
\ 'javascript': ['prettier'],
\ 'javascriptreact': ['prettier'],
\ 'typescript': ['prettier',],
\ 'typescriptreact': ['prettier',],
\ 'scss': ['prettier'],
\ 'python': [],
\ 'sql': ['sqlformat'],
\}
" \ 'javascript': ['eslint'],
let g:ale_linters = {
\ 'javascript': ['eslint', 'prettier',],
\ 'javascriptreact': ['eslint', 'prettier',],
\ 'typescript': ['tsserver', 'standard', 'eslint', 'prettier',],
\ 'typescriptreact': ['tsserver', 'standard', 'eslint', 'prettier',],
\ 'python': ['pylsp', 'flake8'],
\ 'php': ['php', 'langserver', 'phan'],
\ 'scss': ['scsslint'],
\ 'sql': ['sql-lint'],
\}
let g:ale_linters_explicit = 1
let g:ale_completion_enabled = 1

let g:ale_typescript_prettier_use_local_config = 1

let g:ale_javascript_prettier_use_local_config = 1
let g:ale_javascript_eslint_use_global = 1
let g:ale_javascript_eslint_executable = '/opt/homebrew/bin/eslint'
" let g:ale_javascript_eslint_options = '--config /Users/zaius/code/beyond/client/.eslintrc.js'
" let g:ale_javascript_eslint_options = '--config /Users/zaius/code/beyond/beacon/js/.eslintrc.json'
let g:ale_javascript_prettier_use_global = 0
" let g:ale_javascript_prettier_executable = '/opt/homebrew/bin/prettier'
" let g:ale_javascript_prettier_options = '--config /Users/zaius/code/beyond/client/.prettierrc.js'

let g:ale_php_langserver_executable = expand('~/.composer/vendor/bin/php-language-server.php')
let g:ale_php_phan_executable = expand('~/.composer/vendor/bin/phan_client')
let g:ale_php_phan_use_client = 1

let g:ale_fix_on_save = 1


" let g:black_virtualenv = $BLACK_ENV
" let g:black_virtualenv = "~/.vim/black-latest"

" https://www.reddit.com/r/vim/comments/12tpf9/per_project_vim_settings/
function! ApplyLocalSettings(dirname)
    " Don't try to walk a remote directory tree -- takes too long, too many
    " what if's
    let l:netrwProtocol = strpart(a:dirname, 0, stridx(a:dirname, "://"))
    if l:netrwProtocol != ""
        return
    endif

    " Convert windows paths to unix style (they still work)
    let l:curDir = substitute(a:dirname, "\\", "/", "g")

    " Walk up to the top of the directory tree
    let l:parentDir = strpart(l:curDir, 0, strridx(l:curDir, "/"))
    if isdirectory(l:parentDir)
        call ApplyLocalSettings(l:parentDir)
    endif

    " Now walk back down the path and source .vimsettings as you find them. This
    " way child directories can 'inherit' from their parents
    let l:settingsFile = a:dirname . "/.vimsettings"
    if filereadable(l:settingsFile)
        exec ":source " . l:settingsFile
    endif
endfunction
autocmd! BufEnter * call ApplyLocalSettings(expand("<afile>:p:h"))



" https://www.vimfromscratch.com/articles/vim-and-language-server-protocol/
nmap K :ALEHover<CR>
let g:ale_set_balloons=1
nmap gr :ALEFindReferences<CR>
nmap gd :ALEGoToDefinition -tab<CR>
let g:ale_python_pylsp_config={
\   'pylsp': {
\     'plugins': {
\       'pycodestyle': {
\         'enabled': v:false,
\       },
\       'flake8': {
\         'enabled': v:false,
\       }
\     },
\   },
\ }

let g:ale_python_flake8_options = '--max-line-length=88 --config=/dev/null '


if exists("g:neovim")
  call plug#begin('~/.config/nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif
  " Git
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'

  " Util
  Plug 'godlygeek/tabular'
  Plug 'nathanaelkane/vim-indent-guides'
  Plug 'junegunn/fzf' " , { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'github/copilot.vim'

  " Syntax
  Plug 'plasticboy/vim-markdown'
  Plug 'pangloss/vim-javascript'
  Plug 'cakebaker/scss-syntax.vim'
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
  Plug 'ekalinin/Dockerfile.vim'
  Plug 'joukevandermaas/vim-ember-hbs'
  Plug 'hail2u/vim-css3-syntax'
  Plug 'cakebaker/scss-syntax.vim'
  Plug 'MaxMEllon/vim-jsx-pretty'
  Plug 'leafgarland/typescript-vim'

  " Python plugins
  Plug 'dense-analysis/ale'
  Plug 'vim-python/python-syntax'

  " Themes
  Plug 'sheerun/vim-wombat-scheme'

  Plug 'psf/black', { 'tag': '23.1.0'}

  if exists("g:neovim")
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  endif

call plug#end()

" Black vim version has to be tied to a specific tag, and vim-plug doesn't allow us to
" install multiple tags of the same plugin. I tried just changing the binary, but the
" base plugin file changes between tags, so it errors out.

syntax enable
" Fix issues with files losing syntax as we scroll around.
" See: https://github.com/vim/vim/issues/2790
syntax sync minlines=10000

" https://unix.stackexchange.com/questions/585019/horizontal-equivalent-of-zz-in-vim
" remember: zs + zH
set sidescrolloff=20


let g:black_fast = 1
let g:black_linelength = 88
let g:black_skip_string_normalization = 1
autocmd BufWritePre *.py execute ':Black'

set background=dark
" Make sure vim knows I only use 256 color terminals now
" http://stackoverflow.com/questions/3761770/iterm-vim-colorscheme-not-working
let &t_Co=256
colorscheme wombat
hi Directory ctermfg=234 ctermbg=228 cterm=none guifg=#242424 guibg=#eae788 gui=none

" http://stackoverflow.com/questions/5845557/in-a-vimrc-is-set-nocompatible-completely-useless
" set nocompatible
let mapleader = ","
inoremap jj <ESC>

set nosmartindent
set autoindent
set copyindent

" enable filetype detection:
filetype on
filetype plugin on
filetype indent on

" Get tabs to work well
set tabstop=2
set expandtab
set shiftwidth=2

" I don't really know the difference between swap and backup - I just know I
" need something to stop losing unsaved files when my computer crashes.
" set backup
set nobackup
set nowritebackup
set undofile
" Undo file location is different for neovim & vim. They are set in their own files

" relative line numbers to make whole line commands easier
set relativenumber

" Show a colored column at line 88
set colorcolumn=88
set textwidth=88

" Default to yanking to the system clipboard.
" Can use fakeclip if clipboard support isn't compiled in
" https://github.com/kana/vim-fakeclip
set clipboard=unnamed

" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full

" display the current mode and partially-typed commands in the status line:
set showmode
set showcmd

" don't make it look like there are line breaks where there aren't:
set nowrap

" make searches case-insensitive, unless they contain upper-case letters:
set ignorecase
set smartcase

" show the `best match so far' as search strings are typed:
set incsearch
" Keep searches highlighted after the search is finished.
set hlsearch
" Clear the search highlight with leader slash
nnoremap <leader>/ :let @/=''<cr>

" allow <BkSpc> to delete line breaks, beyond the start of the current
" insertion, and over indentations:
set backspace=eol,start,indent

" Always have the status bar on
set laststatus=2
set ruler

" Bounce the cursor off the opposite brace
set showmatch

" Fix my inability to use shift properly
"https://stackoverflow.com/questions/117150/can-i-remap-ex-commands-in-vim
command WQ wq
command Wq wq
command W w
command Q q
" ca WQ wq

" Allow saving of files as sudo when I forgot to start vim using sudo.
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! w !sudo tee > /dev/null %

if has("gui_macvim")
  " Don't show the macvim toolbar. Who uses a mouse anyway?!
  set go-=T
  set guifont=Fira\ Code:h16
  set anti

  " Turn off bell. Macvim has no visual bell, so this does the same thing.
  set vb

  " Make Macvim fullscreen actually fill screen
  set fuoptions=maxvert,maxhorz
endif

" Tab navigation
" Can't use ctrl-J as it causes problems with newlines and neovim
" map <C-k> :tabp<CR>
" map <C-j> :tabn<CR>

nmap <C-t> :tabnew<CR>
imap <C-t> <ESC>:tabnew<CR>

" Consistent tabs with browser
nmap <S-D-}> :tabnext<CR>
imap <S-D-}> <ESC>:tabnext<CR>
nmap <S-D-{> :tabprevious<CR>
imap <S-D-{> <ESC>:tabprevious<CR>

nmap <C-S-tab> :tabprevious<CR>
imap <C-S-tab> <ESC>:tabprevious<CR>
nmap <C-tab> :tabnext<CR>
imap <C-tab> <ESC>:tabnext<CR>

nmap <D-]> :tabnext<CR>
imap <D-]> <ESC>:tabnext<CR>
nmap <D-[> :tabprevious<CR>
imap <D-[> <ESC>:tabprevious<CR>

" Easier non-interactive command insertion
nnoremap <Space> :


" Leader commands - so much cooler than function keys
map <leader>p :set paste!<CR>:set paste?<CR>
map <Leader>a :Ack<space>

" Trailing whitespace
match Error /\s\+$/
func! ClearTrailingWhitespace()
  %s/\s\+$//ge
  let @/=''
endfunc
nnoremap <leader>w :call ClearTrailingWhitespace()<cr>
autocmd BufWrite :call ClearTrailingWhitespace()<cr>

" Format XML with xmllint with ,x
:vmap <Leader>x !xmllint --nonet --nowarning --nowrap --html --format --recover -<CR>
" :vmap <Leader>x !xmllint --format --recover -<CR>
:vmap <Leader>j !python3 -m json.tool <CR>
:nmap <Leader>j !!python3 -m json.tool <CR>

set notitle

" http://superuser.com/questions/558876
set signcolumn=yes

vmap <Leader>t- :Tabularize /-<CR>
vmap <Leader>t, :Tabularize /,<CR>
vmap <Leader>T, :Tabularize /,\zs<CR>
vmap <Leader>t: :Tabularize /\:<CR>
vmap <Leader>T: :Tabularize /\:\zs<CR>
vmap <Leader>t\| :Tabularize /\|<CR>
vmap <Leader>T\| :Tabularize /\|\zs<CR>
vmap <Leader>t= :Tabularize /=<CR>
vmap <Leader>T= :Tabularize /=\zs<CR>

" https://www.reddit.com/r/vim/comments/1bwo5z/comment/c9db6t0/
vmap <Leader>t, :Tabularize /\v,(([^"]*"[^"]*")*[^"]*$)@=<CR>

" https://github.com/junegunn/fzf.vim
map <C-p> :GFiles<CR>

command! -bang -nargs=* PRg
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
  \ {'dir': system('git -C '.expand('%:p:h').' rev-parse --show-toplevel 2> /dev/null')[:-2]}, <bang>0)


" grep within the folder of the current file
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>),
  \   fzf#vim#with_preview({'dir': expand('%:h')}), <bang>0)

map <C-g> :GGrep<CR>


" TODO: switch to git-better-blame (in /bin)
map <Leader>gb :Git blame<CR>

imap <C-space> <ESC>:ALEComplete<CR>

" Disable folds until manual action is taken
set nofoldenable
map <Leader>f0 :set foldlevel=0<CR>
map <Leader>f1 :set foldlevel=1<CR>
map <Leader>f2 :set foldlevel=2<CR>
map <Leader>f3 :set foldlevel=3<CR>
map <Leader>f4 :set foldlevel=4<CR>
map <Leader>f5 :set foldlevel=5<CR>
map <Leader>f6 :set foldlevel=6<CR>
map <Leader>f7 :set foldlevel=7<CR>
map <Leader>f8 :set foldlevel=8<CR>
map <Leader>f9 :set foldlevel=9<CR>
set foldlevel=99

" Ideally...
" autocmd filetype python source ~/.vim/pydoc.vim
autocmd FileType python setlocal tabstop=4 shiftwidth=4
autocmd FileType python set foldmethod=indent
" hilight tabs as errors
autocmd Filetype python match Error /\t/
" default is tcq in python
" help fo-table for info
autocmd FileType python set formatoptions=cqnrblj

" Use system python for neovim - avoids issues with black when switching between pyenv
" versions
let g:python3_host_prog = '/usr/bin/python3'
" Unfortunately this doesn't work until newer versions of black, but it would solve the
" init of the virtualenv to the wrong version... i couldn't work it out, but next
" install, go to the virtualenv and run:
"   ~/.local/share/nvim/black/bin/pip install black==19.10b0
let g:black_use_virtualenv = 0

" vim-python/python-syntax
" https://github.com/vim-python/python-syntax/blob/master/doc/python-syntax.txt
let g:python_highlight_all = 1

" Javascript
" default is croql
autocmd FileType javascript set formatoptions=cqnrblj
autocmd FileType html.handlebars set noeol

" Markdown
autocmd BufNewFile,BufRead *.md set filetype=markdown
let g:vim_markdown_folding_disabled=1

" New line (with `o`) in a markdown list shouldn't indent
let g:vim_markdown_new_list_item_indent = 0



" Open tag in new tab
" https://stackoverflow.com/questions/563616/vim-and-ctags-tips-and-tricks
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
