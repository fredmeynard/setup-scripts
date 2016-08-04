# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt goodness:
# ~/Code/some_dir(my-git-branch)$
#
# There are variations if there are untracked files (a + will appear), uncommited changes
# (branch colour turns yellow) and if you must pull/push (arrows will appear).

function parse_git_branch {
  # Inits
  GIT_BRANCH=""
  GIT_UNTRACKED=""
  GIT_CLEAN=""
  GIT_REMOTE=""

  # Match patterns
  local branch_pattern="On branch ([^${IFS}]*)"
  local remote_pattern="Your branch is (ahead|behind)"
  local clean_pattern="working directory clean"
  local untracked_pattern="Untracked files"
  local diverge_pattern="Your branch and (.*) have diverged"

  # Get git status
  local git_status="$(git status 2> /dev/null)"

  # Get branch
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    GIT_BRANCH="${BASH_REMATCH[1]}"
  fi

  # Check if our working dir is clean
  if [[ ! ${git_status} =~ ${clean_pattern} ]]; then
    GIT_CLEAN="dirty"
  fi

  # Check for untracked files
  if [[ ${git_status} =~ ${untracked_pattern} ]]; then
    GIT_UNTRACKED="+"
  fi

  # Check if we're ahead or behind
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      GIT_REMOTE="↑"
    elif [[ ${BASH_REMATCH[1]} == "behind" ]]; then
      GIT_REMOTE="↓"
    fi
  fi

  # Check if we diverged
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    GIT_REMOTE="↕"
  fi
}

function awesome_prompt {
  local      BLACK="\[\033[0;30m\]"
  local  BLACKBOLD="\[\033[1;30m\]"
  local        RED="\[\033[0;31m\]"
  local    REDBOLD="\[\033[1;31m\]"
  local      GREEN="\[\033[0;32m\]"
  local  GREENBOLD="\[\033[1;32m\]"
  local     YELLOW="\[\033[0;33m\]"
  local YELLOWBOLD="\[\033[1;33m\]"
  local       BLUE="\[\033[0;34m\]"
  local   BLUEBOLD="\[\033[1;34m\]"
  local     PURPLE="\[\033[0;35m\]"
  local PURPLEBOLD="\[\033[1;35m\]"
  local       CYAN="\[\033[0;36m\]"
  local   CYANBOLD="\[\033[1;36m\]"
  local      WHITE="\[\033[0;37m\]"
  local  WHITEBOLD="\[\033[1;37m\]"

  case $TERM in
    xterm*)
    TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

  # Get git status and fill in status vars
  parse_git_branch

  GIT_PART=""
  if [ "$GIT_BRANCH" != "" ]; then
    # Different colours if working dir isn't clean
    if [[ "$GIT_CLEAN" == "dirty" ]]; then
      GIT_BRANCH_COLOR=$YELLOW
    else
      GIT_BRANCH_COLOR=$GREEN
    fi
    GIT_PART="$BLUE($GIT_BRANCH_COLOR$GIT_BRANCH$YELLOW$GIT_REMOTE$RED$GIT_UNTRACKED$BLUE)"
  fi

  HOSTPART="$BLUE\u@\h"
  MAINPART="$CYAN\w$GIT_PART$WHITE\$ "

  # Without hostname
  export PS1="$TITLEBAR$MAINPART"

  # With hostname:
  # export PS1="$TITLEBAR$HOSTPART $MAINPART"

}
export PROMPT_COMMAND="awesome_prompt"
export PS2='> '
export PS4='+ '

export EDITOR="vim"
# Alternatively:
# export EDITOR="nano"

# Appends to history, don't delete
shopt -s histappend

# Load alias definitions, if present
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Same thing, but for OS X with brew
if [ "$(which brew)" != "" ]  && [ -f $(brew --prefix)/etc/bash_completion.d ]; then
  . $(brew --prefix)/etc/bash_completion.d/*
fi

# rbenv stuff
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# nvm stuff
if [ "$(uname)" == "Darwin" ]; then
  if [ -f $(brew --prefix nvm)/nvm.sh ]; then
    export NVM_DIR=~/.nvm
    source $(brew --prefix nvm)/nvm.sh
  fi
fi
if [ "$(uname)" == "Linux" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
fi

# Postgres.app - Mac only
if [ -d /Applications ]; then
  export PGPATH="/Applications/Postgres.app/Contents/Versions/latest"
fi

# Adjust path
ADDITIONAL_PATHS="/usr/local/bin /usr/local/sbin /usr/local/share/npm/bin $HOME/.rbenv/bin $PGPATH/bin $HOME/bin"
for p in $ADDITIONAL_PATHS; do
  if [ -d $p ] ; then
    PATH="$p:$PATH"
  fi
done

# Path cleanup - remove duplicates
PATH=$(echo -n $PATH | tr ":" "\n" | awk ' !x[$0]++' | tr "\n" ":" | sed 's/:*$//')
