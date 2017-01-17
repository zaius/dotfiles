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
# Also see:
#   http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
#
# I also looked into most - but I can't kick the habit of vim scroll key
# bindings. I'm sure there's remapping, but I didn't get too far into it.
#   http://www.jedsoft.org/most/
man() {
    env \
      LESS_TERMCAP_mb=$(printf "\x1b[38;2;255;200;200m") \
      LESS_TERMCAP_md=$(printf "\x1b[38;2;255;100;200m") \
      LESS_TERMCAP_me=$(printf "\x1b[0m") \
      LESS_TERMCAP_so=$(printf "\x1b[38;2;60;90;90;48;2;40;40;40m") \
      LESS_TERMCAP_se=$(printf "\x1b[0m") \
      LESS_TERMCAP_us=$(printf "\x1b[38;2;150;100;200m") \
      LESS_TERMCAP_ue=$(printf "\x1b[0m") \
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
  reset     "%{[0m%}"
  bold      "%{[1m%}" no-bold      "%{[22m%}"
  italic    "%{[3m%}" no-italic    "%{[23m%}"
  underline "%{[4m%}" no-underline "%{[24m%}"
  blink     "%{[5m%}" no-blink     "%{[25m%}"
  reverse   "%{[7m%}" no-reverse   "%{[27m%}"
)

# Fill the color maps.
for color in {000..256}; do
  FG[$color]="%{[38;5;${color}m%}"
  BG[$color]="%{[48;5;${color}m%}"
done
