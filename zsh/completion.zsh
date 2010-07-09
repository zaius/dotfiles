zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' list-colors ''
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit
