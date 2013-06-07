# Thanks to @holman
alias gs='git status -sb'
alias gd='git diff'
alias grm="git status | grep deleted | awk '{print \$3}' | xargs git rm"
alias gp='git push origin HEAD'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
# Get to the top of the repo
alias cdg='cd `git rev-parse --show-cdup`'
# Stash everything except the index in order to run tests
alias gss='git stash save --include-untracked --keep-index'
# alias git clone --recursive
alias textfiles='git ls-files | xargs file --mime-type | grep "text/" | cut -d: -f1'
alias cleanup_line_endings="textfiles | xargs sed -i '' 's///'"
alias cleanup_tabs="textfiles | xargs sed -i '' 's/	//g'"
alias cleanup_trailing_whitespace="textfiles | xargs sed -i '' 's/ *$//g'"

function cleanup_quotes {
  for FILE in `textfiles`; do
    iconv -f utf8 -t ascii//TRANSLIT < $FILE > $FILE.new
    mv $FILE.new $FILE
  done
}
