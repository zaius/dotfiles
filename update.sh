#!/bin/bash
# Update all submodules
git submodule init
git submodule update
git submodule foreach git pull origin master
