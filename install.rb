#!/usr/bin/ruby

require 'fileutils'

ROOT = File.expand_path('../', __FILE__)
HOME = ENV['HOME']

# In case I forgot to run clone --recursive
`git -C #{ROOT} submodule update --init`

# TODO: pop this off argv
force = false


# Copy files that can't be symlinks (e.g. .forward)
Dir["#{ROOT}/**/**.copy"].each do |file|
  output_file = HOME + '/.' + File.basename(file, '.copy')
  FileUtils.rm_rf output_file if File.exists?(output_file) || File.symlink?(output_file)
  FileUtils.cp file, output_file
end

# Link files into home directory
Dir["#{ROOT}/**/**.symlink"].each do |file|
  next if file.include? 'undo'

  output_file = HOME + '/.' + File.basename(file, '.symlink')

  if !force && File.exists?(output_file) && !File.symlink?(output_file)

    print "#{output_file} will be overwritten. Delete it? "
    if gets.chomp.upcase.start_with? 'Y'
      puts "Overwriting #{output_file}"
      # Have to use recursive as it could be a directory (eg. vim)
      FileUtils.rm_rf output_file
    else
      puts "Ignoring #{output_file}"
    end
  end

  File.delete output_file if File.symlink? output_file

  puts "Linking #{file} to #{output_file}"
  File.symlink file, output_file
end

# TODO: overwriting .ssh sucks. Want to leave what's in there, and maybe even
# append to authorized_keys. No good way to append, no good way to link into
# a directory
