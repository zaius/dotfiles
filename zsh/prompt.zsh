# Thanks to phil for all the title setting stuff
# http://aperiodic.net/phil/prompt/

preexec () {
  if [[ "$TERM" == "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}


setprompt () {
  setopt prompt_subst

  # See if we can use colors.
  autoload colors zsh/terminfo
  if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
  fi

  for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
  done
  PR_NO_COLOUR="%{$terminfo[sgr0]%}"


  # Decide if we need to set titlebar text.
  case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    ;;
  *)
    PR_TITLEBAR=''
    ;;
  esac
    
    
    # Decide whether to set a screen title
  if [[ "$TERM" == "screen" ]]; then
    PR_STITLE=$'%{\ekzsh\e\\%}'
  else
    PR_STITLE=''
  fi
    
    
  # Finally, the prompt.
  PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
$PR_CYAN%n@%m$PR_NO_COLOR:$PR_LIGHT_RED%~$PR_NO_COLOUR%# '
}

setprompt
