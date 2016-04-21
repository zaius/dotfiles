autoload colors && colors

if [[ $platform == 'Darwin' ]]; then
  alias ls='gls --color=auto'
  alias dircolors='gdircolors'

  if which grc > /dev/null; then
    source "`brew --prefix`/etc/grc.bashrc"
  fi

elif [[ $platform == 'Linux' ]]; then
  alias ls='ls --color=auto'
fi

eval "`dircolors ~/.dircolors`"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

# grc.bashrc auto-colorizes diff for us, but here for posterity
# command which grc > /dev/null && diff() { grc diff -u $@ | less }

# Use colors for man pages. Courtesy of:
#   http://superuser.com/questions/602295/how-do-you-change-the-background-color-of-man-pages
#
# I also looked into most - but I can't kick the habit of vim scroll key
# bindings. I'm sure there's remapping, but I didn't get too far into it.
#   http://www.jedsoft.org/most/
man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}


# bg and fg env variables are just basic 16 terminal colors. This env hack sets
# up a similar setup but with Copied from:
#   https://github.com/sykora/etc/blob/master/zsh/functions/spectrum/
#
# To see all the possible colors:
#   for color in {000..256}; echo -n "$FG[$color]#"

# We define three associative arrays, for effects, foreground colors and
# background colors.
typeset -Ag FX FG BG

FX=(
  reset     "[00m"
  bold      "[01m" no-bold      "[22m"
  italic    "[03m" no-italic    "[23m"
  underline "[04m" no-underline "[24m"
  blink     "[05m" no-blink     "[25m"
  reverse   "[07m" no-reverse   "[27m"
)

# Fill the color maps.
for color in {000..256}; do
  FG[$color]="[38;5;${color}m"
  BG[$color]="[48;5;${color}m"
done
