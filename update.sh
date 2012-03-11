#!/bin/bash
# Update all submodules and compile command-t

git submodule init
git submodule update
git submodule foreach git pull origin master

cd vim/vim.symlink/bundle/command-t/ruby/command-t
ruby extconf.rb
make
sudo make install
