: ${UNAME=$(uname)}
: ${INPUTRC=~/.inputrc}

# SHELL OPTIONS

setopt appendhistory extendedglob notify interactivecomments HIST_IGNORE_DUPS
unsetopt autocd beep nomatch

# disable core dumps
ulimit -S -c 0

# Use emacs bindings
bindkey -e

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

MOSH_TITLE_NOPREFIX="YES"
export MOSH_TITLE_NOPREFIX

# PATH

function test_add() {
  test -d "$1" && PATH="$1:$PATH"
}

test_add "$HOME/.rvm/bin"

test_add "/usr/local/texlive/2015/bin/x86_64-darwin"
test_add "/usr/local/bin"

test_add "$HOME/bin"
test_add "$HOME/local/bin"
test_add "$HOME/local/arcanist/bin"
test_add "$HOME/local/ghc/bin"
test_add "$HOME/.cabal/bin"
test_add "$HOME/.smackage/bin"
test_add "$HOME/.local/bin"
test_add "$HOME/.stack/programs/x86_64-osx/ghc-7.10.2/bin"
test_add "$HOME/local/polyml/bin"
test_add "$HOME/src/cakeml/HOL/bin"
test_add "/Applications/Racket v6.7/bin"

test_add "/usr/local/Cellar/llvm/3.4/bin"
#test_add "/usr/local/Cellar/llvm36/3.6.1/bin"


# COMPLETION

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 5
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' special-dirs true

autoload -Uz compinit
autoload bashcompinit
compinit
bashcompinit

source ~/.zsh/completion/*
# enable extra completion if available
test -d /usr/local/share/zsh-completions &&
    fpath=(/usr/local/share/zsh-completions $fpath)

eval "$(stack --bash-completion-script "$(which stack)")"


# ENVIRONMENT CONFIGURATION

# enable en_US locale w/ utf-8 encodings
: ${LANG:="en_US.UTF-8"}: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"

# PAGER & EDITOR

HAVE_VIM=$(command -v vim)
HAVE_EC=$(command -v ec)

# EDITOR
test -n "$HAVE_EC" &&
    EDITOR=ec ||
    EDITOR=vim

export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# Ack
ACK_PAGER="$PAGER"
ACK_PAGER_COLOR="$PAGER"

if [ "$UNAME" == "Darwin" ]; then
    # X11

    LIBRARY_PATH=/opt/X11/lib:$LIBRARY_PATH
    export LIBRARY_PATH

    DYLD_FALLBACK_LIBRARY_PATH=/usr/local/lib:/lib:/usr/lib:/opt/X11/lib
    export DYLD_FALLBACK_LIBRARY_PATH

    PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig:$PKG_CONFIG_PATH
    PKG_CONFIG_PATH=/usr/local/Cellar/libffi/3.0.13/lib/pkgconfig:$PKG_CONFIG_PATH
    export PKG_CONFIG_PATH

    LS_COMMON="-hBGF"

    alias chrome='/usr/bin/open -a "/Applications/Google Chrome.app"'
fi

if [ "$UNAME" == "Linux" ]; then
    # we always pass these to ls(1)
    LS_COMMON="-hF --color"

    test "$TERM" = "rxvt-unicode" &&
        TERM="xterm"
fi

if [ "$UNAME" == "FreeBSD" ]; then
    # we always pass these to ls(1)
    LS_COMMON="-hBGF"
fi


# Set terminal title
precmd () { print -Pn "\e]0;%n@%m: %~\a" }

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$'$(vcs_info_wrapper)'

PROMPT="%F{red}%n%f at %F{yellow}%M%f in %B%F{blue}%~%f%b
%# "

export PROMPT


export CLICOLOR="yes"

# if the dircolors utility is available, set that up to
#dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
    alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"
alias ll.="ls -ld .*"

# OPAM configuration
. /Users/adam/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
