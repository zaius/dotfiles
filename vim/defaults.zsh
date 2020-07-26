# Make macvim's zoom button maximize in height and width
# Sorry Steve.
# Other defaults viewable here:
# http://code.google.com/p/macvim/wiki/UserDefaults
if [[ $platform == 'Darwin' ]]; then
  defaults write org.vim.MacVim MMZoomBoth 1
  # Allow more tabs
  defaults write org.vim.MacVim MMTabMinWidth 50
fi
