#!/bin/bash
#
# TODO:
#  * check if symlink already exists
#  * drop symlink naming?
#  * notice when files added and error out? would have to keep symlink notation...
#  * ensure shell set to zsh
#
set -e
base=~/.dotfiles

home-link() {
  local src=${base}/${1}
  local default_dst=~/.$(basename ${1} .symlink)
  local dst=${2:-$default_dst}

  echo "linking $src to $dst"
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
home-link git/gitignore.symlink
home-link inputrc.symlink
home-link ipython.symlink
home-link irssi.symlink
home-link pdbrc.symlink
home-link powconfig.symlink
home-link psqlrc.symlink
home-link pythonrc.symlink
home-link ruby/gemrc.symlink
home-link ruby/irbrc.symlink
home-link ruby/pryrc.symlink
home-link tmux.conf.symlink
home-link vim/vimrc.symlink
home-link zsh/zshrc.symlink
home-link profile.symlink
home-link alacritty.yml.symlink
