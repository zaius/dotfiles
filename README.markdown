# dotfiles: ~/.*

My attempt at dotfiles. Mostly to make my multi-machine lifestyle easier, but
also here for your enjoyment. Clone this repo to ~/.dotfiles, then run
bash install.sh to link all files ending with .symlink into your home directory.

## Fresh Mac

```bash
git clone https://github.com/zaius/dotfiles.git ~/.dotfiles && bash ~/.dotfiles/install.sh
```

This clones the repo, installs Homebrew + everything in the `Brewfile` (CLI tools, GUI
apps, fonts, App Store apps), switches your login shell to homebrew bash, and links the
`.symlink` files into `~`. The first `git` invocation will prompt to install Xcode
Command Line Tools if they're missing.
