# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
if [[ $- == *i* ]]; then
  if [[ -e /usr/local/opt/fzf/shell/completion.bash ]]; then
    source /usr/local/opt/fzf/shell/completion.bash 2> /dev/null
  elif [[ -e /usr/share/bash-completion/completions/fzf ]]; then
    source /usr/share/bash-completion/completions/fzf 2> /dev/null
  else
    echo '*** FZF completions not found'
  fi
fi

# Key bindings
# ------------

if [[ -e /usr/local/opt/fzf/shell/key-bindings.bash ]]; then
  source "/usr/local/opt/fzf/shell/key-bindings.bash"
elif [[ -e /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
  source "/usr/share/doc/fzf/examples/key-bindings.bash"
else
  echo '*** FZF keybindings not found'
fi
