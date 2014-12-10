#!/bin/bash
# A basically sane bash environment.
#
# Ryan Tomayko <http://tomayko.com/about> (with help from the internets).

# the basics
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# complete hostnames from this file
: ${HOSTFILE=~/.ssh/known_hosts}

# readline config
: ${INPUTRC=~/.inputrc}

# ----------------------------------------------------------------------
#  SHELL OPTIONS {{{
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
      . /etc/bashrc

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell >/dev/null 2>&1
shopt -s extglob >/dev/null 2>&1
shopt -s histappend >/dev/null 2>&1
shopt -s hostcomplete >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

# fuck that you have new mail shit
unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
umask 0022

# }}}
# ----------------------------------------------------------------------
# PATH {{{
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" &&
    PATH="$HOME/bin:$PATH"

test -d "$HOME/local/bin" &&
    PATH="$HOME/local/bin:$PATH"

test -d "/usr/texbin" &&
    PATH="/usr/texbin:$PATH"

# }}}
# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION {{{
# ----------------------------------------------------------------------

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=yes ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=yes ;;
    *)  unset LOGIN ;;
esac

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"

# history stuff
HISTCONTROL=ignoreboth
HISTFILESIZE=10000
HISTSIZE=10000

# }}}
# ----------------------------------------------------------------------
# PAGER / EDITOR {{{
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)
HAVE_MVIM=$(command -v mvim)

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
# ----------------------------------------------------------------------
# PROMPT {{{
# ----------------------------------------------------------------------

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
elif hostname | grep -q 'github\.com'; then
    GITHUB=yep
    COLOR1="\[\e[0;94m\]"
    COLOR2="\[\e[0;92m\]"
    P="\$"
elif hostname | grep -q 'remote.+?chalmers\.se'; then
    P='chalmers:'
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P=">"
fi

prompt_path_compact() {
    unset PROMPT_COMMAND
    PS1="${GREEN}\w${PS_CLEAR}${P} "
    PS2="> "
}

# }}}
# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC {{{
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    # vim aliases
    
    MVIMOPTS="--remote-silent"

    vim() { ${HOME}/bin/mvim ${MVIMOPTS} ${@}; }
    vimdiff() { ${HOME}/bin/mvim ${MVIMOPTS} -d ${@}; }
    export -f vim
    export -f vimdiff

    # put haskell executables on the path
    test -d "$HOME/Library/Haskell/bin" &&
        PATH="$HOME/Library/Haskell/bin:$PATH"

    test -x /usr/pkg -a ! -L /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }
    
fi

# }}}
# ----------------------------------------------------------------------
# LINUX SPECIFIC {{{
# ----------------------------------------------------------------------

if [ "$UNAME" = Linux ]; then
    # put haskell executables on the path
    test -d "$HOME/.cabal/bin" &&
        PATH="$HOME/.cabal/bin:$PATH"
    
    test "$TERM" = "rxvt-unicode" &&
        TERM="xterm"
fi

# }}}
# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS {{{
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
alias du1='du -h --max-depth=1'
alias fn='find . -name'
alias hi='history | tail -20'

# }}}
# ----------------------------------------------------------------------
# BASH COMPLETION {{{
# ----------------------------------------------------------------------

test -z "$BASH_COMPLETION" && {
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    test -n "$PS1" && test $bmajor -gt 1 && {
        # search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /usr/pkg/etc/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion \
                 $HOME/.bash_completion \
                 $HOME/.bash_completion.d/*
        do
            test -f $f && {
                . $f
                break
            }
        done
    }
    unset bash bmajor bminor
}

# override and disable tilde expansion
_expand() {
    return 0
}

# }}}
# ----------------------------------------------------------------------
# LS AND DIRCOLORS {{{
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hBGF"
export CLICOLOR="yes"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
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

# }}}
# --------------------------------------------------------------------
# MISC COMMANDS {{{
# --------------------------------------------------------------------

# push SSH public key to another box
push_ssh_cert() {
    local _host
    test -f ~/.ssh/id_dsa.pub || ssh-keygen -t dsa
    for _host in "$@";
    do
        echo $_host
        ssh $_host 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_dsa.pub
    done
}

# }}}
# --------------------------------------------------------------------
# PATH MANIPULATION FUNCTIONS {{{
# --------------------------------------------------------------------

# Usage: pls [<var>]
# List path entries of PATH or environment variable <var>.
pls () { eval echo \$${1:-PATH} |tr : '\n'; }

# Usage: pshift [-n <num>] [<var>]
# Shift <num> entries off the front of PATH or environment var <var>.
# with the <var> option. Useful: pshift $(pwd)
pshift () {
    local n=1
    [ "$1" = "-n" ] && { n=$(( $2 + 1 )); shift 2; }
    eval "${1:-PATH}='$(pls |tail -n +$n |tr '\n' :)'"
}

# Usage: ppop [-n <num>] [<var>]
# Pop <num> entries off the end of PATH or environment variable <var>.
ppop () {
    local n=1 i=0
    [ "$1" = "-n" ] && { n=$2; shift 2; }
    while [ $i -lt $n ]
    do eval "${1:-PATH}='\${${1:-PATH}%:*}'"
       i=$(( i + 1 ))
    done
}

# Usage: prm <path> [<var>]
# Remove <path> from PATH or environment variable <var>.
prm () { eval "${2:-PATH}='$(pls $2 |grep -v "^$1\$" |tr '\n' :)'"; }

# Usage: punshift <path> [<var>]
# Shift <path> onto the beginning of PATH or environment variable <var>.
punshift () { eval "${2:-PATH}='$1:$(eval echo \$${2:-PATH})'"; }

# Usage: ppush <path> [<var>]
ppush () { eval "${2:-PATH}='$(eval echo \$${2:-PATH})':$1"; }

# Usage: puniq [<path>]
# Remove duplicate entries from a PATH style value while retaining
# the original order. Use PATH if no <path> is given.
#
# Example:
#   $ puniq /usr/bin:/usr/local/bin:/usr/bin
#   /usr/bin:/usr/local/bin
puniq () {
    echo "$1" |tr : '\n' |nl |sort -u -k 2,2 |sort -n |
    cut -f 2- |tr '\n' : |sed -e 's/:$//' -e 's/^://'
}

# }}}
# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT {{{
# -------------------------------------------------------------------

# bring in rbdev functions
. rbdev 2>/dev/null || true

# source ~/.shenv now if it exists
test -r ~/.shenv &&
. ~/.shenv

# condense PATH entries
PATH=$(puniq $PATH)
MANPATH=$(puniq $MANPATH)

# Use the color prompt by default when interactive
test -n "$PS1" &&
  prompt_path_compact

# }}}
# -------------------------------------------------------------------
# MOTD / FORTUNE {{{
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}

# }}}
# vim: ts=4 sts=4 shiftwidth=4 expandtab