# dotfiles: ~/.*
My attempt at dotfiles. Mostly to make my multi-machine lifestyle easier, but
also here for your enjoyment. Clone this repo to ~/.dotfiles, then run 
ruby install.rb to link all files ending with .symlink into your home directory.

## My setup
Mac OS X on the desktop, Ubuntu on the server.

* Mac: brew, macvim
* Ubuntu: screen, vim
* Both: zsh

## Cool stuff

### Secrets
Putting your dotfiles up on github means that you have to leave some personal
information out. I use ERB to render those files with data from a single 
secrets file, meaning only one file has to be copied by hand.

Add your secrets to the secrets.yml file. All files ending with .erb will be 
rendered before the symlinks are created. You can then use ERB in any of the 
template files, and access SECRETS as a hash.

See git/gitconfig.symlink for an example

### Screen Agent
Because SSH agent forwarding depends on environment variables, it breaks when 
you try and use it from a re-attached screen. To fix this, every new zsh shell
dumps the correct environment variables to a fixssh file, which is sourced 
before every command from within the screen, which means your agent should 
forward correctly.

## Thanks
Symlinking strategy heavily inspired by 
[holman's dotfiles](http://github.com/holman/dotfiles),
which in turn were inspired by
[ryanb's dotfiles](http://github.com/ryanb/dotfiles).

The ERB implementation was based on ryanb's rakefile as well.

Also, thanks to all those random people I copied great tidbits off over the 
last 10 years.

## Todo
* Unified ls colors between mac and linux
* prompt for secrets that don't exist
* split vimrc into managable parts - how to source multiple files?
* don't hard code the ~/.dotfiles location
* better / bold vim colors
