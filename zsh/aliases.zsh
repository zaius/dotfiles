alias socks="ssh -D localhost:8000 kelso.id.au"
alias vi="vim"

# http://superuser.com/questions/106637/less-command-clearing-screen-upon-exit-how-to-switch-it-off
alias less="less -X -R --quit-if-one-screen"

# Keep user environment when using sudo
alias sudo="sudo -E"

# Naming of screen titles.
# Escape sequence is: ESC k name ESC \
# These are literal esc chars - ctrl-v ESC
title () { echo -n "k$@\\" }
