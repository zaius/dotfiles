#!/bin/bash
set -euo pipefail

log() {
  cyan=$(tput setaf 6)
  reset=$(tput sgr0)
  echo " ${cyan}-- $*${reset}"
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Mac App Store sign-in (mas can't auth, must happen in the GUI) ---
if grep -q '^mas ' "$here/Brewfile"; then
  log "Opening App Store — sign in if you aren't already"
  open -a "App Store"
  read -r -p " -- Press enter once signed in to continue..."
fi

# --- Everything from the Brewfile (idempotent) ---
log "brew bundle"
brew bundle --file="$here/Brewfile"

# --- fzf keybindings + completions, no rc edits (dotfiles own that) ---
"$(brew --prefix)/opt/fzf/install" --all --no-update-rc

# --- Login shell -> homebrew bash ---
brew_bash="$(brew --prefix)/bin/bash"
if ! grep -qx "$brew_bash" /etc/shells; then
  log "Registering $brew_bash in /etc/shells"
  echo "$brew_bash" | sudo tee -a /etc/shells >/dev/null
fi
if [ "${SHELL:-}" != "$brew_bash" ]; then
  log "chsh -> $brew_bash"
  chsh -s "$brew_bash"
fi

# --- nvm working dir ---
mkdir -p "$HOME/.nvm"

# --- macOS defaults ---
# Disable press-and-hold so vim key-repeat works.
defaults write -g ApplePressAndHoldEnabled -bool false

log "Done. Manual follow-ups: sign into 1Password, Dropbox, Tailscale; install Firefox extensions (uBlock, 1Password, I still don't care about cookies); App Store apps if any."
