# Reinstallation manifest. Apply with: brew bundle --file=Brewfile

# Lines ending in `if laptop` skip the worker, the always-on Mac installed with
# DOTFILES_ROLE=worker (see install.sh). brew hides every variable but its own
# HOMEBREW_ ones from a Brewfile, so read the role install.sh saved instead.
role_file = File.expand_path("~/.dotfiles/.role")
laptop = !File.exist?(role_file) || File.read(role_file).strip != "worker"

# --- Taps ---
tap "hashicorp/tap"

# --- CLI tools ---
brew "bash"
brew "bash-completion@2"
brew "carapace" # flag completions with descriptions
brew "delta" # nicer git diffs
brew "duckdb"
brew "fzf"
brew "gh"
brew "grep" # GNU grep, put ahead of BSD grep on PATH in profile.symlink
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
brew "rust"
brew "uv"
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
cask "chatgpt" if laptop
brew "opencode"


# --- Browsers ---
cask "firefox"
cask "tor-browser" if laptop
cask "ungoogled-chromium" # quarantine stripped post-install in mac.sh

# --- Productivity / windowing ---
cask "1password"
cask "1password-cli"
cask "bitwarden" if laptop
cask "dropbox"
cask "karabiner-elements" if laptop
cask "obsidian"
cask "rectangle" if laptop
cask "monitorcontrol" if laptop


# --- Networking ---
cask "tailscale-app"

# --- Media / drawing / editing ---
cask "monodraw" if laptop
cask "vlc" if laptop
# Until they work out their crashing issues...
# cask "vimr"
cask "neovide" if laptop

# --- Meetings ---
cask "zoom" if laptop
cask "slack" if laptop
cask "discord" if laptop
cask "whatsapp" if laptop

# --- Fonts ---
cask "font-fira-code"

# --- Mac App Store ---
# Requires being signed into the App Store first; `mas` cannot sign you in.
mas "Xcode", id: 497799835
mas "Microsoft Word", id: 462054704 if laptop
mas "Microsoft Excel", id: 462058435 if laptop

# iOS apps still unsupported, but if that eventually changes
# https://github.com/mas-cli/mas/issues/321
# mas "amaran", id: 6503329243
mas "amaran Desktop", id: 6590629064 if laptop
