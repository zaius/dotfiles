if [[ $platform == 'Darwin' ]]; then
  alias vi='mvim'
  alias vim='mvim'
elif which nvim > /dev/null; then
  alias vi='nvim'
  alias vim='nvim'
elif which vim > /dev/null; then
  alias vi='vim'
fi
