autoload colors && colors

setprompt () {
  setopt prompt_subst

  # Nesting vars between %{ and %} tells zsh to ignore them when determining
  # prompt length. Would be nice to redefine color arrays with these specified.

  PROMPT='%{$fg[red]%}%?:\
%{$fg_bold[cyan]%}%n\
%{$fg_bold[red]%}@\
%{$fg_bold[cyan]%}%m:\
%{$fg_bold[red]%}%~\
%{$fg_no_bold[default]%}%# '
}

setprompt
