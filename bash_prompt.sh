#!/usr/bin/env bash

export GIT_PS1_SHOWCWDTYSTATE=true
export GIT_PS1_SHOWCOLORHINTS=true

function on_mac () {
  [[ $OSTYPE == *"darwin"* ]]
}

function my_prompt() {

  local black='\[\e[30m\]'
  local red='\[\e[31m\]'
  local green='\[\e[32m\]'
  local yellow='\[\e[33m\]'
  local blue='\[\e[34m\]'
  local purple='\[\e[35m\]'
  local cyan='\[\e[36m\]'
  local white='\[\e[37m\]'
  local orange='\[\e[208m\]'
  local bold='\[\e[1m\]'
  local reset_color='\[\e[0m\]'

  if on_mac; then
    local SED_CMD="sed -E"
  else
    local SED_CMD="sed -r"
  fi

  local main_color=$green
  local highlight_color=$white
  local gitroot_color=$highlight_color
  local branch_color=$white
  local prompt_color=$white

  # IF ROOT, USE ALT COLORS
  if [ $EUID -eq 0 ]; then
    local main_color=$red
    local branch_color=$cyan
  fi

  local GITROOT=$( git rev-parse --show-toplevel 2> /dev/null )

  if [ ${#GITROOT} -ge 1 ]; then
    local GITREPO=$( basename $GITROOT )

    PS1="${bold}${main_color}[${gitroot_color}$GITREPO"

    local SUBDIR=$( pwd \
      | $SED_CMD "s:${GITROOT}(.*):\1:"
    )

    if [ ${#SUBDIR} -ge 1 ]; then
      local BASENAME=$( basename $SUBDIR )
      local SUBDIR=$( echo $SUBDIR \
        | $SED_CMD 's:^(.*/)[^/]+$:\1:' \
        | $SED_CMD 's:^(/[^/]+/).+(/)$:\1…\2:'
      )
      PS1+="${main_color}$SUBDIR${highlight_color}$BASENAME"
    fi

    PS1+="${main_color}]"

    local GITBRANCH=$( git symbolic-ref --short HEAD 2> /dev/null )

    if [ ${#GITBRANCH} -ge 1 ]; then
      PS1+=":[${branch_color}$GITBRANCH${main_color}]"
    fi

  else

    local WORKING_DIRECTORY=$( pwd )

    local HOME_DIRNAME=$( dirname $HOME )

    local CWD=$( echo $WORKING_DIRECTORY \
      | $SED_CMD 's:^(.*/)[^/]+$:\1:' \
      | $SED_CMD "s:^(${HOME_DIRNAME}/*[^/]*)(.*)$:~\\2:" \
      | $SED_CMD 's:^(~/*[^/]+/|/[^/]+/).+(/[^/]+/)$:\1…\2:'
    )

    local BASENAME=$( echo $WORKING_DIRECTORY \
      | $SED_CMD "s:^(${HOME_DIRNAME}/[^/]+|.*/)([^/]+)*$:\\2:" \
    )

    PS1="${bold}${main_color}[$CWD"

    if [ ${#BASENAME} -ge 1 ]; then
      PS1+="${highlight_color}$BASENAME"
    fi

    PS1+="${main_color}]"

  fi

  PS1+=":${prompt_color}\\$ "
  PS1+="${reset_color}"

  if [ $VTE_INTEGRATION_PS1_SUFFIX ]; then
    PS1+=$VTE_INTEGRATION_PS1_SUFFIX
  fi

  PS2="${bold}${main_color}:${prompt_color}>${reset_color} "

}

export PROMPT_COMMAND=my_prompt
