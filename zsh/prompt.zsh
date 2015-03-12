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
