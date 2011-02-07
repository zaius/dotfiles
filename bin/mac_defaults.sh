#!/bin/bash

# Always use LCD subpixel rendering
# http://01welp.co.uk/2010/05/sub-pixel-rendering-in-mac-os-x/
defaults -currentHost write -globalDomain AppleFontSmoothing -int 2

# Make chrome quit on command-shift-q instead of just command-q
defaults write com.google.Chrome NSUserKeyEquivalents '{"Quit Google Chrome"="@$Q";}
