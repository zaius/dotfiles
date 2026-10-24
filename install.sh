#!/bin/bash
#
# TODO:
#  * check if symlink already exists
#  * drop symlink naming?
#  * notice when files added and error out? would have to keep symlink notation...
#
set -e
base=~/.dotfiles

# Run straight from curl on a fresh machine: clone the repo first. A fresh Mac
# only has the /usr/bin/git stub, which pops the Command Line Tools installer
# and exits, so trigger the install here and wait for it to finish.
if [[ ! -d $base ]]; then
  if [[ "$(uname -s)" == "Darwin" ]] && ! xcode-select -p >/dev/null 2>&1; then
    echo "installing Command Line Tools - click Install in the dialog"
    xcode-select --install
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  fi
  git clone https://github.com/zaius/dotfiles.git ${base}
  # Fetch anonymously over https, but push over ssh since GitHub rejects
  # password auth for https pushes.
  git -C ${base} remote set-url --push origin git@github.com:zaius/dotfiles.git
fi

home-link() {
  local src=${base}/${1}
  local default_dst=~/.$(basename ${1} .symlink)
  local dst=${2:-$default_dst}

  echo "linking $src to $dst"
  if [[ ! -e $src ]]; then
    echo "warning - no source file found"
    return
  fi

  [[ -L $dst ]] && rm $dst
  if [[ -e $dst ]]; then
    echo "warning - removing original $dst"
    rm -r $dst
  fi

  ln -s $src $dst
}

# Link .ssh first so that password only require once
home-link ssh.symlink ~/.ssh
chmod g-w ~/.dotfiles/ssh.symlink

home-link config.symlink ~/.config
home-link vim/vim.symlink ~/.vim

home-link dircolors.symlink
home-link git/gitconfig.symlink
home-link git/gitconfig.beyond.symlink
home-link git/gitignore.symlink
home-link inputrc.symlink
home-link ipython.symlink
home-link psqlrc.symlink
home-link pythonrc.symlink
home-link tmux.conf.symlink
home-link vim/vimrc.symlink
home-link profile.symlink
# home-link eslintrc.json.symlink

# macOS: install Homebrew + Brewfile + GUI apps. Run after linking so the CLI
# logins and Karabiner write into the linked ~/.config, which home-link would
# otherwise delete.
if [[ "$(uname -s)" == "Darwin" ]]; then
  bash "${base}/mac.sh"
fi

# launchd agents (copied, not linked - launchd is unreliable with symlinked plists)
if [[ "$(uname -s)" == "Darwin" ]]; then
  mkdir -p ~/Library/LaunchAgents
  for plist in ${base}/launchd/*.plist; do
    echo "installing launch agent $(basename ${plist})"
    cp ${plist} ~/Library/LaunchAgents/
    launchctl bootout gui/$(id -u)/$(basename ${plist} .plist) 2>/dev/null || true
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/$(basename ${plist})
  done
fi
