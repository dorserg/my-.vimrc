set nocompatible
filetype off

" manage plugins {{{
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'Conque-Shell'
Bundle 'Parameter-Text-Objects'
Bundle 'taglist.vim'
Bundle 'vimwiki'

Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdcommenter'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'msanders/snipmate.vim'
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'michaeljsmith/vim-indent-object'

Bundle 'git://git.wincent.com/command-t.git'
" }}}

syntax on
filetype plugin indent on

runtime! macros/matchit.vim
runtime! ftplugin/man.vim

set history=999
set ruler
set number
set showcmd
set matchpairs+=<:>
set laststatus=2
set incsearch
set hlsearch
set noswapfile
set nobackup
set nowrap
set hidden
set mouse=a

set wildmode=longest,full
set wildmenu

" always pass 'g' flag to :s command
set gdefault

map Y y$

set tabstop=4
set shiftwidth=4
set expandtab

set splitbelow
set splitright

set ignorecase
set smartcase

" stuff from example_vimrc {{{
inoremap <C-U> <C-G>u<C-U>

" jump to the last known cursor position
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	    \ | wincmd p | diffthis
endif
" }}}

nnoremap q <Nop>
nnoremap Q q
let mapleader = "q"

nnoremap <F5> :set hls!<Bar>set hls?<CR>

nnoremap <F6> :set paste!<Bar>set paste?<CR>
set pastetoggle=<F6>

" fuzzy search for files and buffers
function! SmartFufFile()
    let path = fnamemodify(bufname("%"), ":p:~:h")
    if (path == "~")
        echo "no way, it's home directory"
        return
    endif
    exe "FufFileWithCurrentBufferDir **/"
endfunction

map ,f :call SmartFufFile()<CR>
map ,b :FufBuffer<CR>

" open file under cursor in vertical window, not horizontal
map <C-w>f :vsplit<CR>gf

" quickfix made quicker
map cn :cn<C-M>
map cp :cp<C-M>
map cr :cr<C-M>
map cl :cla<C-M>
map cc :cc<C-M>

set guioptions-=m " turn off menu bar
set guioptions-=T " turn off toolbar

" autoload cscope database {{{
function! LoadCscope()
    let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path = strpart(db, 0, match(db, "/cscope.out$"))
        set nocsverb " suppress 'duplicate connection' error
        exe "cs add " . db . " " . path
        set csverb   " switch back to verbose mode
    endif
endfunction
au BufEnter /* call LoadCscope()
" }}}

" search for selected text, forwards or backwards {{{
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
" }}}

" write with sudo
" note that this will reload the buffer which means all history is lost
noremap :W :w !sudo tee % > /dev/null

nmap gb :!git blame %<CR>

autocmd! BufReadPost  ~/.vimrc setl foldmethod=marker
autocmd! BufWritePost ~/.vimrc source %

nmap gs :Sex<CR>

" replace visual selection without overwriting default register {{{
function! RestoreRegister()
    let @" = s:restore_reg
    return ''
endfunction
function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction
vnoremap <silent> <expr> p <sid>Repl()
" }}}

set tags=tags;/

map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

nmap ,w :w<CR>

" python settings {{{
function! PythonAutocommands()
    nnoremap <buffer> <F2> :w<CR>:!python %<CR>
    nnoremap <buffer> <F3> :w<CR>:!python -i %<CR>
endfunction

augroup python_autocommands
    au!
    au FileType python call PythonAutocommands()
augroup END
" }}}

" java settings {{{
function! JavaAutocommands()
    setl makeprg=ant\ -find
    setl efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
endfunction

augroup java_autocommands
    au!
    au FileType java call JavaAutocommands()
augroup END
" }}}

" c++ settings {{{
function! CppCommands()
    setl makeprg=g++\ -g\ -Wno-deprecated\ -O2\ %\ -o\ %<
    nnoremap <buffer> <F2> :w<CR>:make<CR>
    nnoremap <buffer> <F3> :!./%<<CR>
    nmap <buffer> <F4> <F2><F3>
endfunction

augroup cpp_commands
    au!
    au FileType cpp call CppCommands()
augroup END
" }}}

" html settings {{{
augroup html_commands
    au!
    au FileType html,xml inoremap <buffer> </ </<C-X><C-O>
augroup END
" }}}

let g:vimwiki_folding=1

" create blank newlines and stay in normal mode
nnoremap <silent> zj o<Esc>
nnoremap <silent> zk O<Esc>

let g:EasyMotion_keys = "abcdefghijklmnopqrstuvwxyz"
let g:EasyMotion_leader_key = '['

let g:SuperTabDefaultCompletionType = "<c-n>"

" taglist plugin {{{
let Tlist_Show_One_File=1
let Tlist_Use_Right_Window=1
let Tlist_Enable_Fold_Column=0
let Tlist_Compact_Format=1
nmap <leader>to :TlistOpen<C-M>
nmap <leader>tt :TlistToggle<C-M>
" }}}

set guioptions=aegit
set textwidth=78

if (!has("gui_running"))
    colorscheme koehler
endif

vnoremap < <gv
vnoremap > >gv

" make it a goddamn habbit, bro!
inoremap <C-h> <left>
inoremap <C-k> <up>
inoremap <C-j> <down>
inoremap <C-l> <right>

noremap 0 ^
noremap ^ 0

" dumb scroll-other-window
nmap j <C-l><C-e><C-h>
nmap k <C-l><C-y><C-h>

