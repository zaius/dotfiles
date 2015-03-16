# For more inspiration, check out oh my zsh themes:
#  * https://github.com/robbyrussell/oh-my-zsh/wiki/themes
# In hindsight, probably should have just copied these:
#  * https://gist.github.com/agnoster/3712874
#  * https://github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme
#  * http://joshsymonds.com/blog/2014/06/12/shell-awesomeness-with-prezto/
#
# Test font support with:
#   echo '⮀ ± ⭠ ➦ ✔ ✘'
#
#   Tons of different codes for powerline chars
#   forward arrow: \ue0b0
#   back arrow: \ue0b2

# Variable scoping in zsh is weird...
last_bg='none'
side='left'
RETVAL=0
local orange=210
local red=128
local cyan=084
local magenta=111
local black=000
local white=007

c() {
  # Nesting vars between %{ and %} tells zsh to ignore them when determining
  # prompt length. (P) tells zsh to lookup the variable name inside the local
  # scope. See: http://stackoverflow.com/questions/8376395/zsh-and-dynamic-variable
  echo -n "\
%{$BG[${(P)1}]%}\
%{$FG[${(P)2}]%}\
"
}

user_prompt() {
  [[ $USER == zaius ]] && return;
  # I wasted hours on this. Before I had this:
  # pcolor=%(!.magenta.cyan)
  # echo $pcolor
  # Which looks fine when you compare the output, however the % codes are only
  # for PS1 expansion - they don't happen in a regular echo expansion.
  # Therefore they only get evaluated when they're actually printed to screen,
  # so can't use it as a function arg.
  # echo $pcolor | hexdump -c
  [[ $UID -eq 0 ]] && pcolor=red || pcolor=cyan

  arrow $pcolor
  c $pcolor black
  echo -n ' %n '
}

host_prompt() {
  [[ $HOST == pro ]] && return;

  arrow white
  c white black
  echo -n ' %m '
}

# ZSH has a vcs_info command for pulling out the branch info - no need to do it
# by hand.
# http://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html
#
# Don't want to override an existing precmd here - can append to it.
# TODO: probably should move this add-zsh-hook to zshrc
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git

# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
zstyle ':vcs_info:git:*' formats ':%b'
zstyle ':vcs_info:git:*' actionformats ' GIT ACTION! [%b|%a]'

git_info() {
  [[ -z "$vcs_info_msg_0_" ]] && return;
  arrow orange
  c orange black
  echo -n " $vcs_info_msg_0_ "
}


# Maybe look at tr for stripping out leading spaces to fix the shitty formatting
# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-bash-variable
exit_code() {
  [[ $RETVAL == 0 ]] && return

  arrow black
  c black red
  echo -n "$RETVAL "
}

directory() {
  arrow magenta
  c magenta black
  echo -n ' %~ '
}

arrow() {
  if [[ $side == 'right' ]]; then
    c $last_bg $1
    echo -n ''
    last_bg=$1
    c $1 $last_bg
    echo -n ' '
    return
  fi

  if [[ $last_bg == 'none' ]]; then
    last_bg=$1
    return
  fi

  c $1 $last_bg
  echo -n ''
  last_bg=$1
}

build_prompt() {
  # NOTE: this has to go first, before any variable assignment or subcommands.
  RETVAL=$?
  last_bg='none'
  side='left'

  exit_code
  user_prompt
  host_prompt
  directory
  arrow black
  # TODO: transparent instead of black? default instead of white?
  c black white
}

right_prompt() {
  last_bg='none'
  side='right'

  git_info
  c black white
}


setopt prompt_subst
PROMPT='$(build_prompt) '
RPROMPT='$(right_prompt) '
# What does this do? Can't find doc for it anywhere...
#   prompt_opts=(cr subst percent)
# A bunch of scripts put the prompt setting in the pre-cmd. Is there any point?
#   add-zsh-hook precmd prompt_precmd
