# Reinstallation manifest. Apply with: brew bundle --file=Brewfile

# --- Taps ---
tap "hashicorp/tap"

# --- CLI tools ---
brew "bash"
brew "bash-completion@2"
brew "delta" # nicer git diffs
brew "duckdb"
brew "fzf"
brew "gh"
brew "htop"
brew "just"
brew "mas" # mac app store installer
brew "libpq"
brew "postgresql@18" # provides psql; libpq is keg-only
brew "neovim"
# brew "nmap"
brew "pspg"
brew "pgcli"
brew "pwgen"
brew "pyenv"
brew "restic" # nightly backups to B2, see bin/backup
brew "tmux"
brew "wget"
brew "xz"
brew "zstd" # unpacks bin/migrate archives

# Youtube
brew "ffmpeg"
brew "yt-dlp"


# --- Dev ---
cask "orbstack"
brew "go"
brew "hashicorp/tap/terraform", trusted: true
brew "honcho" # Procfile runner
brew "libpostal" # C library behind the postal python bindings in prettydata
brew "mkcert" # local CA for the kestrel/prettydata certs, restored in mac.sh
brew "nss" # certutil, so mkcert -install can trust the CA in Firefox
brew "xcodegen" # generates the Noted xcodeproj
# --- Terminals ---
cask "ghostty"
cask "kitty"
# --- CLIs
cask "azure-cli"
brew "cloudflare-wrangler"
brew "doctl"
cask "gcloud-cli"
cask "sentry-cli"
# --- JS toolchain ---
brew "node"
brew "pnpm"
brew "eslint"
brew "prettier"


# --- AI ---
cask "claude-code@latest"
cask "codex"
cask "claude"
cask "chatgpt"
brew "opencode"


# --- Browsers ---
cask "firefox"
cask "tor-browser"
cask "ungoogled-chromium" # quarantine stripped post-install in mac.sh

# --- Productivity / windowing ---
cask "1password"
cask "1password-cli"
cask "bitwarden"
cask "dropbox"
cask "karabiner-elements"
cask "obsidian"
cask "rectangle"
cask "kitlangton-hex"
cask "monitorcontrol"


# --- Networking ---
cask "tailscale-app"

# --- Media / drawing / editing ---
cask "monodraw"
cask "vlc"
# Until they work out their crashing issues...
# cask "vimr"
cask "neovide"

# --- Meetings ---
cask "zoom"
cask "slack"
cask "discord"

# --- Fonts ---
cask "font-fira-code"

# --- Mac App Store ---
# Requires being signed into the App Store first; `mas` cannot sign you in.
mas "Xcode", id: 497799835
mas "Microsoft Word", id: 462054704
mas "Microsoft Excel", id: 462058435

# iOS apps still unsupported, but if that eventually changes
# https://github.com/mas-cli/mas/issues/321
# mas "amaran", id: 6503329243
mas "amaran Desktop", id: 6590629064
