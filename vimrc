set backspace=2
syntax on
filetype indent on
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set autoindent
autocmd BufWritePre * %s/\s\+$//e
