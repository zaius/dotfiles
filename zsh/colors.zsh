if [[ $platform == 'Darwin' ]]; then
  alias ls='gls --color=auto'
  alias dircolors='gdircolors'
elif [[ $platform == 'Linux' ]]; then
  alias ls='ls --color=auto'
fi

eval "`dircolors ~/.dircolors`"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
