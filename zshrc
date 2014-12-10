#!/usr/local/bin/zsh

: ${UNAME=$(uname)}
: ${INPUTRC=~/.inputrc}

# SHELL OPTIONS

setopt appendhistory extendedglob notify interactivecomments
unsetopt autocd beep nomatch

# disable core dumps
ulimit -S -c 0

# Use emacs bindings
bindkey -e

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 5
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' special-dirs true

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

autoload -Uz compinit
compinit
autoload bashcompinit
bashcompinit

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

MOSH_TITLE_NOPREFIX="YES"
export MOSH_TITLE_NOPREFIX

# PATH

function test_add() {
  test -d "$1" && PATH="$1:$PATH"
}

test_add "/usr/texbin"

test_add "$HOME/bin"
test_add "$HOME/local/bin"

test_add "$HOME/local/arcanist/bin"

test_add "/usr/local/opt/ruby/bin"

test_add "/usr/local/mysql/bin"

test_add "/usr/local/bin"

# Haskell stuff
test_add "$HOME/local/ghc/bin"
test_add "$HOME/.cabal/bin"

test_add "/usr/local/Cellar/llvm/3.4/bin"

# ENVIRONMENT CONFIGURATION

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"

# enable extra completion if available
test -d /usr/local/share/zsh-completions &&
  fpath=(/usr/local/share/zsh-completions $fpath)

[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# PAGER & EDITOR

HAVE_VIM=$(command -v vim)

# EDITOR
test -n "$HAVE_VIM" &&
    EDITOR=vim ||
    EDITOR=vi

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

# }}}
# ----
# OS SPECIFIC {{{
# ----

# Nix packages
if [ -e /Users/adam/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/adam/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

if [ "$UNAME" == "Darwin" ]; then
    # we always pass these to ls(1)
    LS_COMMON="-hBGF"

    test -x /usr/pkg -a ! -L /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }
fi

if [ "$UNAME" == "Linux" ]; then
    # we always pass these to ls(1)
    LS_COMMON="-hF --color"

    test "$TERM" = "rxvt-unicode" &&
        TERM="xterm"
    
    test -d "$HOME/local/share/perl5" &&
        PERL5LIB="$HOME/local/share/perl5:$PERL5LIB"
fi

if [ "$UNAME" == "FreeBSD" ]; then
    # we always pass these to ls(1)
    LS_COMMON="-hBGF"
fi

# }}}
# ----
# PROMPT {{{
# ----

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

# }}}
# ----
# LS & COLORS {{{
# ----

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
alias chrome='/usr/bin/open -a "/Applications/Google Chrome.app"'

# }}}
# ----
# MISC COMMANDS {{{
# ----

# push SSH public key to another box
push_ssh_cert() {
    local _host
    test -f ~/.ssh/id_rsa.pub || ssh-keygen -t rsa
    for _host in "$@"; do
        echo $_host
        ssh $_host 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
    done
}

cabal_install_sandbox() {
  if [ "$#" -lt "1" ]; then
    echo "Usage: install_cabal_sandbox [binary]"
  else
    ln -s "$(pwd)/.cabal-sandbox/bin/$1" ~/.cabal/bin/
  fi
}

with_sandbox() {
  echo PATH="./cabal-sandbox/bin:$PATH" $@
  PATH="./cabal-sandbox/bin:$PATH" $@
}

#cabal_sandbox_path() {
#}

# }}}
# ----
# ALIASES {{{
# ----

test -e ~/.aliases && source .aliases

# }}}

# vim: ts=4 sts=4 shiftwidth=4 expandtab

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting


# PLUGINS

# zsh-bd
. $HOME/.zsh/plugins/bd/bd.zsh
