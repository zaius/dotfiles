alias socks="ssh -D localhost:8000 kelso.id.au"
alias vi="vim"
alias mv="mv -i"
command which gawk > /dev/null && alias awk=gawk

# http://superuser.com/questions/106637/less-command-clearing-screen-upon-exit-how-to-switch-it-off
alias less="less --ignore-case --no-init --RAW-CONTROL-CHARS --quit-if-one-screen --quit-at-eof"

# Keep user environment when using sudo
alias sudo="sudo -E"

# Naming of screen titles.
# Escape sequence is: ESC k name ESC \
# These are literal esc chars - ctrl-v ESC
title () { echo -n "k$@\\" }

# plutil args are impossible to remember
alias p2j="plutil -convert json -r -o - -- -"

ff () {
  find . -iname "*$@*"
}

# Work in progress
ssh() {
  export local_hash=$(git --work-tree=$HOME/.dotfiles --git-dir=$HOME/.dotfiles/.git rev-parse --verify HEAD)
  command ssh "$@" -t "env origin_hash=$local_hash zsh -i"
}

# Run upon login
export local_hash=$(git --work-tree=$HOME/.dotfiles --git-dir=$HOME/.dotfiles/.git rev-parse --verify HEAD)
if [[ ("${origin_hash}" != "") && ("${origin_hash}" != $local_hash) ]]; then
  echo "dotfiles don't match"
fi
