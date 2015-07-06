alias socks="ssh -D localhost:8000 kelso.id.au"
alias vi="vim"
alias mv="mv -i"
command which gawk > /dev/null && alias awk=gawk
command which grc > /dev/null && diff() { grc diff -u $@ | less }


# Use colors for man pages. Courtesy of:
#   http://superuser.com/questions/602295/how-do-you-change-the-background-color-of-man-pages
#
# I also looked into most - but I can't kick the habit of vim scroll key
# bindings. I'm sure there's remapping, but I didn't get too far into it.
#   http://www.jedsoft.org/most/
man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}

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
# This was originally against HEAD, but that means unpushed local changes will
# always trigger a re-install but will never match the local hash.
ssh() {
  export local_hash=$(git -C $HOME/.dotfiles rev-parse --verify origin/master)
  command ssh "$@" -t "env origin_hash=$local_hash zsh -i"
}

# Run upon login
export local_hash=$(git -C $HOME/.dotfiles rev-parse --verify HEAD)
if [[ ("${origin_hash}" != "") && ("${origin_hash}" != $local_hash) ]]; then
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
  command ssh $@ 'sudo chsh -s `which zsh` `whoami`'
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
