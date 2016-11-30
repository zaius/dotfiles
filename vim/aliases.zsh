if [[ $platform == 'Darwin' ]]; then
  alias vi='vimr'
  alias vim='vimr'
  # Stick with neovim until I can patch vimr to block
  export EDITOR="nvim"
elif which nvim > /dev/null; then
  alias vi='nvim'
  alias vim='nvim'
  export EDITOR="nvim"
elif which vim > /dev/null; then
  alias vi='vim'
  export EDITOR="vim"
fi
