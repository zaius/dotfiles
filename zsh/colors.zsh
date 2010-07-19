if [[ $platform == 'Darwin' ]]; then
  export LSCOLORS=Dxfxcxdxbxegedabagacad
  alias ls="ls -G"
elif [[ $platform == 'Linux' ]]; then
  if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
  fi
  alias ls='ls --color=auto'
fi

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
