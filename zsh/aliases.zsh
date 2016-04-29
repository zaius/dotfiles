alias socks="ssh -D localhost:8000 kelso.id.au"
alias vi="vim"
alias mv="mv -i"
command which gawk > /dev/null && alias awk=gawk

alias iostat='sudo iostat -xtc 5'

# http://superuser.com/questions/106637/less-command-clearing-screen-upon-exit-how-to-switch-it-off
alias less="less --ignore-case --RAW-CONTROL-CHARS --quit-if-one-screen"

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
# This was originally against HEAD, but that means unpushed local changes will
# always trigger a re-install but will never match the local hash.
#
# Assuming zsh on remote causes all sorts of issues. Breaks when sshing to routers, breaks when zsh not installed, etc.
# ssh() {
#   export local_hash=$(git -C $HOME/.dotfiles rev-parse --verify origin/master)
#   command ssh "$@" -t "env origin_hash=$local_hash zsh -i -l"
#   # command ssh "$@" -t "env origin_hash=$local_hash echo 'hi there'; \$(which zsh > /dev/null) && zsh -i || bash -i"
# }
ssh() {
  export local_hash=$(git -C $HOME/.dotfiles rev-parse --verify origin/master)
  LC_local_hash=$local_hash command ssh $@
}

# Run upon login
export local_hash=$(git -C $HOME/.dotfiles rev-parse --verify HEAD)
if [[ ("${LC_local_hash}" != "") && ("${origin_hash}" != $LC_local_hash) ]]; then
  echo "dotfiles don't match"
  # tmux keeps hold of old dotfiles somehow. There's probably a way to tell it
  # not to, but this is my hacky workaround.
  if [[ -z "$TMUX_PANE" ]]; then
    git -C $HOME/.dotfiles pull
    ruby $HOME/.dotfiles/install.rb
    # can't run logout here as we're not in a login shelll
    exit
  fi
fi

install-dotfiles() {
  command ssh $@ 'which git && which ruby && which zsh'
  if [[ $? != 0 ]]; then
    echo 'Dependency missing'
    return 1
  fi
  command ssh $@ 'sudo chsh -s `which zsh` zaius'
  command ssh $@ 'ssh-keyscan github.com >> ~/.ssh/known_hosts'
  command ssh $@ 'git clone git@github.com:zaius/dotfiles.git .dotfiles'
  command ssh $@ 'ruby .dotfiles/install.rb'
}

beyond-dev-init() {
  sed -i .bak -n '/Host beyond.dev/,/^$/ ! p' ~/.ssh/config
  cd ~/code/beyondpricing-devops
  vagrant ssh-config --host beyond.dev >> ~/.ssh/config
  install-dotfiles beyond.dev
}
