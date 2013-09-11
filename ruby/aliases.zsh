alias bundle_production='bundle install --without development test --deployment --binstubs'

gem() {
  # Oh hi future david! You're reading this because you typed `which gem` but
  # gem is actually a function. You can remove it with 'unset -f gem' but this
  # is probably what you want to do: command which gem

  if [[ $@ == "uninstall all" ]]; then
    command gem list --no-versions | xargs -L1 gem uninstall -aIx
  else
    command gem "$@";
  fi;
}

# Run rake from the bundle if it exists.
#
# It would be nice to do this with all executables inside a bundle, but I can't
# find a nice way to get bundler to show me all the executables.
# This gives a list of all executables in a bundle, but then I would have to run
# it before every command. Could keep a cache?
# ruby -e "require 'bundler'; puts Bundler.load.specs.map(&:executables).flatten.inspect"
#
# More ways to handle specs:
# http://stackoverflow.com/questions/9322078/programmatically-determine-gems-path-using-bundler/9322317#9322317
#
# Rails does weird shit to make this not nescessary for the rails executable
# http://yehudakatz.com/2011/05/30/gem-versioning-and-bundler-doing-it-right/
rake() {
  if [[ -e "./Gemfile.lock" ]] && `grep -q rake Gemfile.lock`; then
    echo "Running rake from bundle"
    command bundle exec rake "$@"
  else
    command rake "$@"
  fi
}
