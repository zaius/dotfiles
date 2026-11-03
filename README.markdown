# dotfiles: ~/.*

My attempt at dotfiles. Mostly to make my multi-machine lifestyle easier, but
also here for your enjoyment. Clone this repo to ~/.dotfiles, then run
bash install.sh to link all files ending with .symlink into your home directory.

## Fresh Mac

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zaius/dotfiles/main/install.sh)"
```

This installs the Xcode Command Line Tools if they're missing (click Install in the
dialog), clones the repo to `~/.dotfiles`, installs Homebrew + everything in the
`Brewfile` (CLI tools, GUI apps, fonts, App Store apps), switches your login shell to
homebrew bash, and links the `.symlink` files into `~`. Use `bash -c "$(curl …)"`, not
`curl … | bash` — the setup prompts read from the terminal. Re-running it (or
`bash ~/.dotfiles/install.sh`) skips the clone.

## Worker Mac

An always-on Mac for background Claude sessions, scheduled tasks and daemons:

```bash
DOTFILES_ROLE=worker bash -c "$(curl -fsSL https://raw.githubusercontent.com/zaius/dotfiles/main/install.sh)"
```

The role sticks (in the gitignored `.role`), so re-runs need no variable. A worker skips
the Brewfile lines marked `if laptop`, never sleeps, turns on Remote Login and Screen
Sharing, stops installing macOS updates by itself, logs in automatically when FileVault is
off, and opens Claude Desktop at login for its scheduled tasks. It also runs the launch
agents in `launchd/worker/`: `so.kel.claude-remote` serves Remote Control sessions from
`~/code`, which you can start from claude.ai/code or the Claude app. Logs go to
`~/Library/Logs/claude-remote.log`.

Afterwards, by hand:

 * turn off Tailscale key expiry for the Mac (mac.sh reminds you)
 * clone the repos it should work on into `~/code`
 * add user-scoped MCP servers (`claude mcp add --scope user …`): they live in
   `~/.claude.json`, which stays per Mac

## Manual steps remaining

 * add google accounts
   * add contact syncing
   * no mail
 * login to everything
 * add ignored folders to spotlight
