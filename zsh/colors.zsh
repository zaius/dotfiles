autoload colors && colors

if [[ $platform == 'Darwin' ]]; then
  alias ls='gls --color=auto'
  alias dircolors='gdircolors'
elif [[ $platform == 'Linux' ]]; then
  alias ls='ls --color=auto'
fi

eval "`dircolors ~/.dircolors`"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'


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
