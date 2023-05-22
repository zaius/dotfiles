#!/bin/bash
set -e

brew=/opt/homebrew/bin/brew
$brew install \
  bash \
  fzf \
  bash-completion@2 \
  pyenv \
  nvm \
  nomad \
  neovim \
  htop \
  # For python extensions
  xz \
  nmap

mkdir ~/.nvm
/opt/homebrew/opt/fzf/install


echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash zaius


# Use system python
/usr/bin/pip3 install \
  black==23.1.0 \
  neovim \
  # python-language-server is unmaintained
  python-lsp-server[all]


pyenv install 3.9.5
pyenv install 3.10.6


wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip


$brew install prettier


# Ensure chrome can actually launch
# https://www.reddit.com/r/MacOS/comments/q9d772/homebrew_chromium_is_damaged_and_cant_be_openend/
# https://dev.to/tnzk/install-puppeteer-on-macbook-pro-with-apple-silicon-m1-3kc
$brew install chromium --no-quarantine
# Use local chromium for puppeteer so we can avoid rosetta
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

defaults write -g ApplePressAndHoldEnabled -bool false


$brew install google-cloud-sdk
# pip3 install gcloud gsutil
#
# Git color diffs
$brew install git-delta
$brew install libpq

$bew install pyls



# Avoid wireguard sending all DNS requests via tunnel
# In case wireguard mac ever supports PostUp, injecting the wifi nameservers into the
# wireguard interface would likely be better. Didn't get as far as setting them, but
# this gets them:
#   scutil --dns | grep --before 2 'if_index.*en0' | grep nameserver | cut -d ' ' -f 5 | sort | uniq
sudo mkdir -p /etc/resolver
echo nameserver 10.128.0.1 | sudo tee /etc/resolver/prd
echo search prd | sudo tee -a /etc/resolver/prd
echo nameserver 10.128.0.1 | sudo tee /etc/resolver/internal
echo search us-central1-f.c.beyond-pricing-1024.internal | sudo tee -a /etc/resolver/internal


urls=(
  # Drag and drop
  'https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg'
  'https://get.videolan.org/vlc/3.0.18/macosx/vlc-3.0.18-arm64.dmg'
  # pkg installers
  'https://zoom.us/client/5.13.7.15481/zoomusInstallerFull.pkg?archType=arm64'
)


curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin


command mkdir "$tdir/mp"
command hdiutil attach "$installer" "-mountpoint" "$tdir/mp" || die "Failed to mount kitty.dmg"
command ditto -v "$tdir/mp/kitty.app" "$dest"
command hdiutil detach "$tdir/mp"
command rm -rf "$tdir"
