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


curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin


# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


brew=/opt/homebrew/bin/brew
$brew install \
  bash \
  fzf \
  bash-completion@2 \
  libpq \
  pyenv \
  nvm \
  nomad \
  neovim \
  htop \
  nmap \
  pyenv \
  wget \
  1password-cli \
  `# For python extensions` \
  xz

mkdir ~/.nvm
/opt/homebrew/opt/fzf/install


echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash zaius



mkdir fira
curl --location https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip > fira.zip
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




# TODO:
# * orbstack
# * dropbox
# * 1pass
# * firefox
# * rectangle
# * karabiner
# * zoom
#
#
#
# Firefox
#   * ublock
#   * 1pass
#   * i still don't care about cookies
#
# Tailscale

# Drag and drop
app_urls=(
  'https://release.files.ghostty.org/1.3.1/Ghostty.dmg'
  'https://updates.helftone.com/monodraw/downloads/monodraw-latest.dmg'
  'https://get.videolan.org/vlc/3.0.18/macosx/vlc-3.0.18-arm64.dmg'
  'https://github.com/obsidianmd/obsidian-releases/releases/download/v1.2.8/Obsidian-1.2.8-universal.dmg',
  # 'https://desktop.docker.com/mac/main/arm64/Docker.dmg'
  'https://github.com/qvacua/vimr/releases/download/v0.44.0-20230103.174333/VimR-v0.44.0.tar.bz2'
)
# pkg installers
pkg_urls=(
  'https://zoom.us/client/5.13.7.15481/zoomusInstallerFull.pkg?archType=arm64'
)



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
