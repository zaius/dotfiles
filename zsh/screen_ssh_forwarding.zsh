# Idea courtesy of:
# http://samrowe.com/wordpress/ssh-agent-and-gnu-screen/
if [[ "$TERM" != "screen" ]]; then
  ~/.ssh/grabssh
fi
preexec () {
  if [[ "$TERM" == "screen" ]]; then
    source $HOME/.ssh/fixssh
  fi
}
