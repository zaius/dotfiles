gem() {
  # Oh hi future david! You're reading this because you typed `which gem` but
  # gem is actually a function. You can remove it with 'unset -f gem' but this
  # is probably what you want to do: command which gem

  if [[ $@ == "uninstall all" ]]; then
    command gem list --no-version | xargs gem uninstall -ax
  else
    command gem "$@";
  fi;
}
