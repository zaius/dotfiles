#!/bin/bash
set -euo pipefail

log() {
  cyan=$(tput setaf 6)
  reset=$(tput sgr0)
  echo " ${cyan}-- $*${reset}"
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Cache sudo creds up front, keep alive until script exits ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# --- Mac App Store sign-in (mas can't auth, must happen in the GUI) ---
if grep -q '^mas ' "$here/Brewfile"; then
  log "Opening App Store — sign in if you aren't already"
  open -a "App Store"
  read -r -p " -- Press enter once signed in to continue..."
fi

# --- Everything from the Brewfile (idempotent) ---
log "brew bundle"
brew bundle --file="$here/Brewfile"

# --- Chromium: strip Gatekeeper quarantine (unsigned build, otherwise "damaged") ---
if [ -d "/Applications/Chromium.app" ]; then
  log "Removing Gatekeeper quarantine from Chromium"
  sudo xattr -rd com.apple.quarantine /Applications/Chromium.app || true
fi

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
  sudo chsh -s "$brew_bash" "$USER"
fi

# --- nvm working dir ---
# mkdir -p "$HOME/.nvm"

# --- Computer name (Sharing / Bonjour / hostname) ---
current_name="$(scutil --get ComputerName 2>/dev/null || true)"
log "Current computer name: ${current_name:-<unset>}"
read -r -p " -- New computer name (enter to keep): " new_name
if [ -n "$new_name" ]; then
  # LocalHostName/HostName need a DNS-safe label: spaces -> hyphens, drop other punctuation.
  safe_name="$(echo "$new_name" | tr ' ' '-' | tr -cd 'A-Za-z0-9-')"
  sudo scutil --set ComputerName "$new_name"
  sudo scutil --set LocalHostName "$safe_name"
  sudo scutil --set HostName "$safe_name"
  dscacheutil -flushcache
fi

# --- macOS defaults ---
# Disable press-and-hold so vim key-repeat works.
defaults write -g ApplePressAndHoldEnabled -bool false
# Fast key repeat, minimal delay
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# No emojis on fn
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

# Trackpad: max tracking speed.
defaults write -g com.apple.trackpad.scaling -float 3.0
# Trackpad: disable Look up & data detectors (both force-click and three-finger tap).
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
# Trackpad: swipe between pages with three fingers (not two).
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1

# View style codes: Nlsv = List, icnv = Icons, clmv = Columns, glyv = Gallery.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
killall Finder

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "right"
# defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.1
killall Dock

# --- Rectangle: launch on login, hide menubar icon ---
# Needs first launch + Accessibility permission before defaults will stick.
if [ -d "/Applications/Rectangle.app" ]; then
  log "Opening Rectangle — grant Accessibility permission when prompted"
  open -a Rectangle
  read -r -p " -- Press enter once Rectangle has Accessibility access to continue..."
  defaults write com.knollsoft.Rectangle launchOnLogin -bool true
  defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
  osascript -e 'quit app "Rectangle"' >/dev/null 2>&1 || true
  open -a Rectangle
fi

# --- Firefox: enterprise policies (DoH via NextDNS, force-install extensions) ---
# Plist lives outside the .app bundle so Firefox auto-updates can't wipe it.
# JSON -> plutil -> defaults import is cleaner than `defaults write -dict` for nested policies.
if [ -d "/Applications/Firefox.app" ]; then
  log "Writing Firefox enterprise policies"
  ff_json="$(mktemp -t firefox_policies).json"
  ff_plist="${ff_json%.json}.plist"
  cat > "$ff_json" <<'EOF'
{
  "EnterprisePoliciesEnabled": true,
  "DNSOverHTTPS": {
    "Enabled": true,
    "ProviderURL": "https://dns.nextdns.io/4bf19c",
    "Locked": false
  },
  "Preferences": {
    "browser.startup.page": {
      "Value": 3,
      "Status": "default"
    }
  },
  "FirefoxHome": {
    "Search": true,
    "TopSites": false,
    "SponsoredTopSites": false,
    "Pocket": true,
    "SponsoredPocket": false,
    "Locked": false
  },
  "3rdparty": {
    "Extensions": {
      "uBlock0@raymondhill.net": {
        "adminSettings": {
          "userFilters": "||accounts.google.com/gsi/*$3p"
        }
      }
    }
  },
  "ExtensionSettings": {
    "uBlock0@raymondhill.net": {
      "installation_mode": "normal_installed",
      "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
    },
    "{d634138d-c276-4fc8-924b-40a0ea21d284}": {
      "installation_mode": "normal_installed",
      "install_url": "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi"
    },
    "idcac-pub@guus.ninja": {
      "installation_mode": "normal_installed",
      "install_url": "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi"
    }
  }
}
EOF
  plutil -convert xml1 "$ff_json" -o "$ff_plist"
  sudo defaults import /Library/Preferences/org.mozilla.firefox "$ff_plist"
  rm -f "$ff_json" "$ff_plist"
fi

# --- Claude Code: pre-seed enabled plugins so first launch only needs a trust confirm ---
# Plugin install requires auth, but seeding settings.json shortcuts the manual /plugin step.
if [ ! -f "$HOME/.claude/settings.json" ]; then
  log "Seeding ~/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  cat > "$HOME/.claude/settings.json" <<'EOF'
{
  "enabledPlugins": {
    "frontend-design@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "playwright@claude-plugins-official": true
  }
}
EOF
fi

# --- Hex: launch on login (no built-in pref, register as login item) ---
if [ -d "/Applications/Hex.app" ]; then
  log "Registering Hex as a login item"
  osascript <<'EOF' >/dev/null
tell application "System Events"
  if not (exists login item "Hex") then
    make login item at end with properties {path:"/Applications/Hex.app", hidden:false}
  end if
end tell
EOF
fi

log "Done. Manual follow-ups: sign into 1Password, Dropbox, Tailscale."
