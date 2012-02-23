autoload colors && colors


# Maybe look at tr for stripping out leading spaces to fix the shitty formatting
# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-bash-variable
exit_code () {
  if [[ $? != 0 ]]; then
    echo "%{$fg[red]%}%?\
%{$fg[default]%}:"
  fi
}

chroot () {
  if [[ $SCHROOT_CHROOT_NAME != "" ]]; then
    echo "%{$fg[red]%} in \
%{$fg[magenta]%}$SCHROOT_CHROOT_NAME"
  fi
}

setprompt () {
  setopt prompt_subst

  # Nesting vars between %{ and %} tells zsh to ignore them when determining
  # prompt length. Would be nice to redefine color arrays with these specified.

  PROMPT='$(exit_code)\
%{$fg_bold[cyan]%}%n\
%{$fg_bold[red]%}@\
%{$fg_bold[cyan]%}%m\
$(chroot)\
:\
%{$fg_bold[red]%}%~\
%{$fg_no_bold[default]%}%# '
}

setprompt
