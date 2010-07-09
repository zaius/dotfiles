if [[ "$TERM" != "screen" ]]; then
  ~/.ssh/grabssh
fi
preexec () {
  if [[ "$TERM" == "screen" ]]; then
    source $HOME/.ssh/fixssh
  fi
}
