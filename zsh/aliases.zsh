alias socks="ssh -D localhost:8000 kelso.id.au"
alias vi="vim"
alias mv="mv -i"
command which gawk > /dev/null && alias awk=gawk

# http://superuser.com/questions/106637/less-command-clearing-screen-upon-exit-how-to-switch-it-off
# -i case insensitive search
alias less="less -i -X -R --quit-if-one-screen"

# Keep user environment when using sudo
alias sudo="sudo -E"

# Naming of screen titles.
# Escape sequence is: ESC k name ESC \
# These are literal esc chars - ctrl-v ESC
title () { echo -n "k$@\\" }

# plutil args are impossible to remember
# alias p2j="plutil -convert json -o - -- - | python -mjson.tool"
alias p2j="plutil -convert json -r -o - -- -"

ff () {
  find . -iname "*$@*"
}
