" Use UTF-8 for reading files and writing new files
set encoding=utf-8
set fileencoding=utf-8

" Set the default clipboard to 'unnamedplus' so that copy (yy) paste (p)
" work from vim to other applications, including the host OS (i.e. the Mac).
set clipboard=unnamedplus

" Stop vim from interpreting modelines in stdin (or normal text files)
" http://stackoverflow.com/questions/8583028/vim-e518-unknown-option
set nomodeline

" Useful programming options

" turn on syntax highlighting
syntax on

" auto-indent tabs
set smartindent

" highlight matches from a search
set hlsearch

" show matches incrementally as search string is entered in ex
set incsearch

" show line numbers
set number

" set case insensitive searching
set ignorecase

