#!/bin/bash
set -e

brew install \
  bash \
  fzf \
  bash-completion@2 \
  pyenv \
  nvm \
  nomad \
  neovim \
  htop


echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash zaius

pyenv install 3.9.5

/usr/bin/pip3 install \
  black==19.10b0 \
  neovim \
  xz # for lzma support for python 3.10?


pyenv install 3.10.6


/opt/homebrew/opt/fzf/install


# Use local chromium for puppeteer so we can avoid rosetta
brew install chromium
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

brew install prettier


# Ensure chrome can actually launch
# https://www.reddit.com/r/MacOS/comments/q9d772/homebrew_chromium_is_damaged_and_cant_be_openend/
# https://dev.to/tnzk/install-puppeteer-on-macbook-pro-with-apple-silicon-m1-3kc
brew install chromium --no-quarantine

defaults write -g ApplePressAndHoldEnabled -bool false


brew install google-cloud-sdk
# pip3 install gcloud gsutil
#
# Git color diffs
brew install git-delta
brew install libpq
