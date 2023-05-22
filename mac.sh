#!/bin/bash
set -ex

quit() {
  red=$(tput setaf 1)
  reset=$(tput sgr0)
  echo " ${red}-- $@${reset}"
  exit 1
}

log() {
  cyan=$(tput setaf 6)
  reset=$(tput sgr0)
  echo " ${cyan}-- $@${reset}"
}
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
  nmap \
  wget \
  `# For python extensions` \
  xz

mkdir ~/.nvm
/opt/homebrew/opt/fzf/install


echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash zaius


# Use system python
/usr/bin/pip3 install \
  black==23.1.0 \
  neovim \
  `# python-language-server is unmaintained` \
  python-lsp-server[all]


/opt/homebrew/bin/pyenv install 3.9.5
/opt/homebrew/bin/pyenv install 3.10.6


mkdir fira
curl --location https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip > fira/fira.zip
unzip -d fira/ fira.zip
rm fira.zip
cp fira/ttf/* /Library/Fonts/
rm -r fira


$brew install \
  prettier \
  eslint
/opt/homebrew/bin/npm install -g typescript


# Ensure chrome can actually launch
# https://www.reddit.com/r/MacOS/comments/q9d772/homebrew_chromium_is_damaged_and_cant_be_openend/
# https://dev.to/tnzk/install-puppeteer-on-macbook-pro-with-apple-silicon-m1-3kc
$brew install chromium --no-quarantine

defaults write -g ApplePressAndHoldEnabled -bool false


$brew install google-cloud-sdk
# pip3 install gcloud gsutil
#
# Git color diffs
$brew install git-delta
$brew install libpq



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


# TODO:
# * wireguard
# * cron

# Drag and drop
app_urls=(
  'https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg'
  'https://get.videolan.org/vlc/3.0.18/macosx/vlc-3.0.18-arm64.dmg'
  'https://github.com/obsidianmd/obsidian-releases/releases/download/v1.2.8/Obsidian-1.2.8-universal.dmg',
  'https://desktop.docker.com/mac/main/arm64/Docker.dmg'
  'https://github.com/qvacua/vimr/releases/download/v0.44.0-20230103.174333/VimR-v0.44.0.tar.bz2'
)
# pkg installers
pkg_urls=(
  'https://zoom.us/client/5.13.7.15481/zoomusInstallerFull.pkg?archType=arm64'
)


# curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

function install_package() {
  tdir='/tmp/install'
  mkdir -p $tdir
  url=$1
  file=`basename $url`
  installer=~/Downloads/$file
  folder="${tdir}/${file%.*}"
  mkdir -p $folder
  curl -L -o $installer $url
  hdiutil attach "$installer" "-mountpoint" "$folder" || quit "Failed to mount image"
  ditto -v `ls -d $folder/*.app` /Applications/
  hdiutil detach "$folder"
  rm -rf "$folder"
}

for url in ${app_urls[@]}; do
  log "Installing: ${url}"
  install_package $url
done
