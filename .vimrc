" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" pathogen: simple package manager
" all plugins are in separate folders under ~/.vim/bundle
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set wildmode=full
set wildmenu

let mapleader = ","

map <F5> :set hls!<bar>set hls?<CR>

" fuzzy search for files and buffers
map <leader>f :FufFileWithCurrentBufferDir **/<CR>
map <leader>b :FufBuffer<CR>

" open file under cursor in vertical window, not horizontal
map <C-w>f :vsplit<CR> <C-w>w gf<CR>

set number

set noswapfile
set nobackup
set nowrap

map <leader>p :w<C-M>:!python %<C-M>
map <leader>P :w<C-M>:!python -i %<C-M>

" ====================================================================
" The following functions and key mappings allow for compiling
" and running simple C++ programs inside Vim. (J. Chung, 4/30/02)
" ====================================================================

" Compile current program (type 'comp' or ,c in command mode)
" This mapping calls the MakeCpp() function defined below.
      map comp :call MakeCpp()
      map <leader>c :w<C-M>comp<C-M>

" Run compiled program (type 'run' or ,r in command mode)
      map run :!./%<
      map <leader>r run<C-M>
      map <leader>R <leader>c<C-M>run<C-M>

" Debug compiled program
      map c_debug :!gdb ./%<
      map <leader>d c_debug<C-M>

" Jump to the next compile error (type 'cn' in command mode)
      map cn :cn<C-M>
" Jump to the previous compile error ('cp')
      map cp :cp<C-M>
" Jump to the 1st compile error ('cr')
      map cr :cr<C-M>
" Jump to the last compile error ('cla')
      map cla :cla<C-M>
" Display current compile error ('cc')
      map cc :cc<C-M>

" Function to compile c++ within vim
      function! MakeCpp()
         set makeprg=g++\ -g\ -Wno-deprecated\ %\ -o\ %<
"         set makeprg=g++\ -Wall\ -pedantic\ %\ -o\ %<
             make
         set makeprg=make
      endfunction

set guioptions-=m " turn off menu bar
set guioptions-=T " turn off toolbar

runtime! ftplugin/man.vim

" autoload cscope database
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

" Search for selected text, forwards or backwards.
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

nmap <leader>tn :tabnew<CR>
nmap <leader>td :tabclose<CR>

map Y y$

set tabstop=4
set shiftwidth=4
set expandtab

noremap :W :w !sudo tee % > /dev/null

" don't save buffers on switching
" saving is quite nasty, e.g. you lose all undo ring
set hidden

nmap gb :!git blame %<CR>

" automatically reload .vimrc when changing
autocmd! bufwritepost ~/.vimrc source %

nmap gs :Sex<CR>

" replace without overwriting default register
nmap [c "_ciw<C-R>"<ESC>
vmap [c "_c<C-R>"<ESC>

set laststatus=2

set tags=tags;/

map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l

let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Compact_Format = 1

nmap [to :TlistOpen<C-M>
nmap [tt :TlistToggle<C-M>

nmap <leader>m :make<C-M>
nmap <leader>w :w<C-M>

augroup java_autocommands
    au!
    au BufEnter *.java setl makeprg=ant\ -find
    au BufEnter *.java setl efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
augroup END

" always pass 'g' flag to :s command
set gdefault

