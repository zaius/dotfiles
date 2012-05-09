gem() {
  if [[ $@ == "uninstall all" ]]; then
    command gem list --no-version | xargs gem uninstall -ax
  else
    command gem "$@";
  fi;
}
