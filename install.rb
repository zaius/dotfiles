#!/usr/bin/ruby

linkables = Dir.glob('**/**{.symlink}')
  
linkables.each do |linkable|
  file = linkable.split('/').last.split('.').first
  `ln -s "$PWD/#{linkable}" "$HOME/.#{file}"`
end
