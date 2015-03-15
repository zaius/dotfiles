autoload colors && colors

c() {
  # Nesting vars between %{ and %} tells zsh to ignore them when determining
  # prompt length.
  echo -n "\
%{$bg[$1]%}\
%{$fg[$2]%}\
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

  echo -n "\
$(c $pcolor black) %n \
$(c $1 $pcolor)⮀\
"
}

host_prompt() {
  [[ $HOST == pro ]] && return;
  echo -n "\
$(c white black) %m \
$(c $1 white)⮀\
"

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
zstyle ':vcs_info:git:*' formats       'git:%b'
zstyle ':vcs_info:git:*' actionformats ' GIT ACTION! [%b|%a]'

git_info() {
  [[ -z "$vcs_info_msg_0_" ]] && return;
  arrow green
  c green black
  echo -n "$vcs_info_msg_0_ "
}


# Maybe look at tr for stripping out leading spaces to fix the shitty formatting
# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-bash-variable
exit_code() {
  [[ $? == 0 ]] && return;

  echo -n "\
$(c black red) %? \
$(c $1 black)⮀\
"
}

setprompt () {
  setopt prompt_subst

  PROMPT='\
$(exit_code blue)\
$(user_prompt white)\
$(host_prompt magenta)\
$(c magenta black) %~ \
$(c default magenta)⮀\
$(c default default) '
}

setprompt
