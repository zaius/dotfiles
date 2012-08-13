# Thanks to @holman
alias gs='git status -sb'
alias gd='git diff'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gp='git push origin HEAD'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
# Get to the top of the repo
alias gcd='cd `git rev-parse --show-cdup`'
# Stash everything except the index in order to run tests
alias gss='git stash save --include-untracked --keep-index'
