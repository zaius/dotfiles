#!/bin/bash
set -e

brew install \
  vim \
  bash \
  fzf \
  awscli \
  node \
  python \
  cscope \
  bash-completion@2


sudo echo '/usr/local/bin/bash' >> /etc/shells
chsh -s /usr/local/bin/bash zaius
