#!/bin/bash
#
# TODO:
#  * check if symlink already exists
#  * drop symlink naming?
#  * notice when files added and error out? would have to keep symlink notation...
# 
set -e
base=~/.dotfiles

home-link() {
  local src=${base}${1}
  local dst=~/.$(basename $1 .symlink)
  [[ -e $dst ]] && rm $dst
  ln -s $src $dst
}

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

ln -s ~/.ssh $base/ssh.symlink
ln -s ~/.config config.symlink
ln -s ~/. $base/vim/vim.symlink
