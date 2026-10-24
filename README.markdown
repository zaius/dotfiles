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

## Manual steps remaining

 * add google accounts
   * add contact syncing
   * no mail
 * login to everything
 * add ignored folders to spotlight
