#!/bin/bash
set -euo pipefail

log() {
  cyan=$(tput setaf 6)
  reset=$(tput sgr0)
  echo " ${cyan}-- $*${reset}"
}

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mirror all output to a log file so silent steps can be tailed from another
# terminal. Password input isn't captured (read -s reads straight from the tty).
logfile="$HOME/mac-setup.log"
exec > >(tee -a "$logfile") 2>&1
log "Run started $(date '+%Y-%m-%d %H:%M:%S') — logging to $logfile"

# --- Full Disk Access ---
# defaults(1) can't write TCC-protected domains (com.apple.universalaccess,
# used below) unless the terminal app has Full Disk Access — without it the
# write errors out and set -e kills the run. Probe by reading a TCC-protected
# plist; its POSIX perms are world-readable, so a failure can only mean TCC.
fda_ok() { plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null 2>&1; }
if ! fda_ok; then
  log "This terminal needs Full Disk Access — opening System Settings"
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
  log "Add/enable your terminal app in the Full Disk Access list"
  read -r -p " -- Press enter once granted to re-check..."
  if ! fda_ok; then
    # FDA only applies to processes launched after the grant, and the OS
    # offers Quit & Reopen for a reason — the running terminal never gains it.
    log "Still no Full Disk Access — quit & reopen the terminal, then re-run mac.sh"
    exit 1
  fi
fi

# --- Sudo: ask once up front, stay warm for the whole run ---
# A `sudo -v` keep-alive loop isn't enough here: every `brew` invocation runs
# `sudo --reset-timestamp` on startup (Library/Homebrew/brew.sh), killing the
# cached credential, and `sudo -n` can never restore it without the password.
# brew and the Homebrew installer both pass `-A` to sudo when SUDO_ASKPASS is
# set, so an askpass helper lets everything re-auth silently. The password
# lives in a 0600 file inside a 0700 tempdir and is deleted on exit.
sudo_dir="$(mktemp -d)"
trap 'rm -rf "$sudo_dir"' EXIT
printf '#!/bin/sh\nexec cat "%s"\n' "$sudo_dir/pw" > "$sudo_dir/askpass"
chmod 700 "$sudo_dir/askpass"
export SUDO_ASKPASS="$sudo_dir/askpass"

log "sudo password — you'll only be asked this once, it stays cached for the whole run"
sudo -k # drop any existing timestamp so we actually validate the password
while :; do
  read -rs -p " -- macOS account password: " sudo_pass
  echo
  (umask 077 && printf '%s\n' "$sudo_pass" > "$sudo_dir/pw")
  unset sudo_pass
  sudo -A -v 2>/dev/null && break
  log "Wrong password, try again"
done

# Route this script's own sudo calls through the askpass helper too, so they
# survive brew's timestamp resets.
sudo() { command sudo -A "$@"; }

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
log "brew bundle — mas apps (Xcode is ~8GB) download with no progress output; watch Launchpad"
brew bundle --file="$here/Brewfile" --verbose

pyenv install --skip-existing 3.15
pyenv global 3.15
curl -LsSf https://astral.sh/uv/install.sh | sh
# The installer drops uv in ~/.local/bin, which profile.symlink puts on PATH,
# but install.sh only links that after this script finishes.
export PATH="$HOME/.local/bin:$PATH"

# ALE execs these as subprocesses, so they only need to be on PATH (isolated uv tools).
# pynvim/black instead live in the provider venv below — Neovim imports them in-process.
uv tool install python-lsp-server[all]
uv tool install flake8
uv tool install black
# Neovim python3 provider: dedicated venv built from the pyenv python so it doesn't
# follow per-project pyenv switching. g:python3_host_prog in common.vim points here.
nvim_venv="$HOME/.local/share/nvim/venv"
uv venv --clear --python "$(pyenv prefix 3.15)/bin/python" "$nvim_venv"
uv pip install --python "$nvim_venv/bin/python" pynvim black


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
# Don't add a period when double-tapping space.
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false

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

# Cursor: bump pointer size a touch (default 1.0, max 4.0).
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5

# View style codes: Nlsv = List, icnv = Icons, clmv = Columns, glyv = Gallery.
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Keep the desktop clean — no mounted volumes or removable media icons.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# New Finder windows open at $HOME.
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
# Show all filename extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
killall Finder

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "right"
# defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.1
# Empty the dock: no pinned apps, no Downloads stack.
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
killall Dock

# Menu bar: show battery percentage.
defaults write com.apple.controlcenter BatteryShowPercentage -bool true
killall ControlCenter

# --- Night Shift (settings live in mac/nightshift.m) ---
# There's no defaults key for this: corebrightnessd owns the settings and
# rewrites its plist from memory, and SIP blocks restarting it. So talk to the
# daemon through CBBlueLightClient, the private CoreBrightness class System
# Settings uses — it applies and persists the change itself, without sudo.
log "Night Shift: 22:00-7:00"
ns_dir="$(mktemp -d)"
if ! { clang -fobjc-arc -framework Foundation -o "$ns_dir/nightshift" "$here/mac/nightshift.m" &&
  "$ns_dir/nightshift"; }; then
  log "Night Shift didn't stick — set it under System Settings > Displays > Night Shift"
fi
rm -rf "$ns_dir"

# Lock screen message.
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If found, please email david@kel.so or text +1 415 519 6574"

# Digital ocean?
# doctl auth init --context mac

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

# --- Karabiner-Elements: approve its driver, background items and permissions ---
# Each needs a click in System Settings, which the app's setup window links to.
# karabiner_cli asks the running agent which step remains, and fails until the
# agent itself is allowed to run in the background.
karabiner_cli="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
karabiner_ready() {
  [ "$("$karabiner_cli" --show-settings-window-guidance 2>/dev/null |
    plutil -extract current_setup raw -o - - 2>/dev/null)" = none ]
}
if [ -x "$karabiner_cli" ] && ! karabiner_ready; then
  log "Opening Karabiner-Elements — approve each step its setup window asks for"
  open -a Karabiner-Elements
  until karabiner_ready; do
    read -r -p " -- Press enter once Karabiner's setup window is done to re-check..."
  done
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
    "Fallback": false,
    "ExcludedDomains": ["rota.kestrel", "dagster.kestrel", "saq.pretty", "dagster.pretty", "rota.pretty"],
    "Locked": false
  },
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  "Handlers": {
    "schemes": {
      "mailto": {
        "action": "useHelperApp",
        "ask": false,
        "handlers": [
          {
            "name": "Gmail",
            "uriTemplate": "https://mail.google.com/mail/?extsrc=mailto&url=%s"
          }
        ]
      }
    }
  },
  "Preferences": {
    "browser.aboutConfig.showWarning": {
      "Value": false,
      "Status": "default"
    },
    "browser.formfill.enable": {
      "Value": false,
      "Status": "default"
    },
    "browser.newtabpage.activity-stream.widgets.sportsWidget.enabled": {
      "Value": false,
      "Status": "default"
    },
    "privacy.globalprivacycontrol.enabled": {
      "Value": true,
      "Status": "default"
    },
    "signon.firefoxRelay.feature": {
      "Value": "disabled",
      "Status": "default"
    },
    "browser.startup.page": {
      "Value": 3,
      "Status": "default"
    },
    "browser.compactmode.show": {
      "Value": true,
      "Status": "default"
    },
    "browser.uidensity": {
      "Value": 1,
      "Status": "default"
    },
    "browser.tabs.tabMinWidth": {
      "Value": 50,
      "Status": "default"
    }
  },
  "FirefoxHome": {
    "Search": true,
    "TopSites": false,
    "SponsoredTopSites": false,
    "Stories": true,
    "SponsoredStories": false,
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
    "playwright@claude-plugins-official": true,
    "swift-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true
  }
}
EOF
fi

# --- Playwright MCP: pin to chromium (default reaches for system Chrome) ---
# Lives inside the marketplace checkout, so plugin updates can clobber it — rewrite
# unconditionally so re-running this script restores the pin.
pw_mcp_dir="$HOME/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/playwright"
log "Pinning Playwright MCP to chromium"
mkdir -p "$pw_mcp_dir"
cat > "$pw_mcp_dir/.mcp.json" <<'EOF'
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest", "--executable-path", "/Applications/Chromium.app/Contents/MacOS/Chromium"]
  }
}
EOF

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

# --- 1Password: sign in first, every login below pulls its password from it ---
if [ -d "/Applications/1Password.app" ]; then
  log "Opening 1Password — sign in if you aren't already"
  open -a 1Password
  read -r -p " -- Press enter once signed in to continue..."
fi

# --- CLI logins: each opens a browser; skipped when already signed in ---
# The tee at the top makes stdout a pipe, which these CLIs read as running
# unattended, so hand them the terminal directly. Open it read-write on all
# three fds: gh queries the background color over stdout and reads the reply
# back from it, so a write-only stdout leaves the reply for its prompt to choke on.
on_tty() { "$@" <>/dev/tty >&0 2>&0; }
log "CLI logins: gh, gcloud, az, sentry-cli"
gh auth status >/dev/null 2>&1 || on_tty gh auth login --web --git-protocol https
gh alias set co 'pr checkout' --clobber >/dev/null
gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | grep -q . || on_tty gcloud auth login
gcloud config set disable_usage_reporting true --quiet 2>/dev/null
az account show >/dev/null 2>&1 || on_tty az login
[ -f "$HOME/.sentryclirc" ] || on_tty sentry-cli login

# --- Secrets from 1Password: restic's B2 key and passphrase, the mkcert CA ---
until op vault list >/dev/null 2>&1; do
  log "Turn on 1Password > Settings > Developer > Integrate with 1Password CLI"
  read -r -p " -- Press enter to retry..."
done

if [ ! -f "$HOME/.restic/password" ]; then
  log "Writing ~/.restic/env and ~/.restic/password for bin/backup"
  restic_item="op://Private/Backblaze - mac-restic"
  mkdir -p "$HOME/.restic"
  chmod 700 "$HOME/.restic"
  op read --force --out-file "$HOME/.restic/password" "$restic_item/passphrase" >/dev/null
  (
    umask 077
    {
      echo 'export RESTIC_REPOSITORY="s3:s3.us-west-000.backblazeb2.com/kelso-mac-backup"'
      echo "export AWS_ACCESS_KEY_ID=$(op read "$restic_item/username")"
      echo "export AWS_SECRET_ACCESS_KEY=$(op read "$restic_item/password")"
    } > "$HOME/.restic/env"
  )
fi

# The kestrel and prettydata boxes serve certs this CA signed, so a fresh CA
# would mean reissuing all of them.
caroot="$(mkcert -CAROOT)"
if [ ! -f "$caroot/rootCA-key.pem" ]; then
  log "Restoring the mkcert CA"
  mkdir -p "$caroot"
  # op filed each attachment as "pem" under a section named for the file.
  op read --force --out-file "$caroot/rootCA.pem" "op://Private/mkcert CA/rootCA/pem" >/dev/null
  op read --force --out-file "$caroot/rootCA-key.pem" "op://Private/mkcert CA/rootCA-key/pem" >/dev/null
fi
on_tty mkcert -install

# --- Documents/Desktop -> Dropbox (run after Dropbox is signed in & synced) ---
log "Opening Dropbox — sign in if you aren't already; Documents/Desktop will be linked into it"
log "WARNING: opt out of Dropbox on File Provider during setup — keep the folder at ~/Dropbox, not ~/Library/CloudStorage"
open -a Dropbox || true
read -r -p " -- Press enter once Dropbox is signed in and the folder exists (or to skip)..."

dropbox_dir=""
for candidate in "$HOME/Dropbox" "$HOME/Library/CloudStorage/Dropbox"; do
  if [ -d "$candidate" ]; then
    dropbox_dir="$candidate"
    break
  fi
done

if [ -z "$dropbox_dir" ]; then
  log "Dropbox folder not found — skipping Documents/Desktop linking"
else
  for name in Documents Desktop; do
    src="$HOME/$name"
    dst="$dropbox_dir/$name"
    if [ -L "$src" ]; then
      log "$name is already a symlink — skipping"
      continue
    fi
    if [ ! -d "$src" ]; then
      log "$src missing — creating link to $dst"
      mkdir -p "$dst"
      ln -s "$dst" "$src"
      continue
    fi
    mkdir -p "$dst"
    # Anything other than .DS_Store / .localized counts as non-empty — prompt until cleared.
    while :; do
      leftover="$(find "$src" -mindepth 1 -not -name '.DS_Store' -not -name '.localized' -print -quit)"
      [ -z "$leftover" ] && break
      log "$src is not empty. Move its contents into $dst, then press enter to re-check (or Ctrl-C to abort)."
      read -r -p " -- Waiting for $src to be empty..."
    done
    log "Replacing $src with link to $dst"
    sudo rm -rf "$src"
    sudo ln -s "$dst" "$src"
  done
fi

log "Done. Manual follow-ups: sign into Tailscale."
