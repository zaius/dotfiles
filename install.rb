#!/usr/bin/ruby
require 'erb'
require 'yaml'
require 'fileutils'

ROOT = File.expand_path('../', __FILE__)
HOME = ENV['HOME']

secrets_file = "#{ROOT}/secrets.yml"
unless File.exists? secrets_file
  puts 'Secrets file missing. Grabbing from kelso.id.au.'
  `scp kelso.id.au:~/.dotfiles/secrets.yml #{ROOT}`
end

SECRETS = YAML.load_file secrets_file


# Parse any ERB files first
Dir['**/**.erb'].each do |file|
  next if file.include? 'undo'

  path = file.split('/')[0..-2].join('/')
  output_file = path + '/' + File.basename(file, '.erb')
  puts "Generating #{output_file} from ERB"

  File.chmod 0600, output_file if File.exists? output_file
  File.open(output_file, 'w') do |new_file|
    new_file.write ERB.new(File.read(file)).result(binding)
  end

  # Disable writes on the file as a reminder that it is generated
  File.chmod 0400, output_file
end


# Copy files that can't be symlinks (e.g. .forward)
Dir['**/**.copy'].each do |file|
  output_file = HOME + '/.' + File.basename(file, '.copy')
  FileUtils.rm_rf output_file if File.exists?(output_file) || File.symlink?(output_file)
  FileUtils.cp ROOT + '/' + file, output_file
end

# Link files into home directory
Dir['**/**.symlink'].each do |file|
  next if file.include? 'undo'

  output_file = HOME + '/.' + File.basename(file, '.symlink')

  if File.exists?(output_file) && !File.symlink?(output_file)

    print "#{output_file} will be overwritten. Delete it? "
    if gets.chomp.upcase == 'Y'
      # Have to use recursive as it could be a directory (eg. vim)
      FileUtils.rm_rf output_file
    else
      abort "Aborted."
    end
  end

  File.delete output_file if File.symlink? output_file

  puts "Linking #{file} to #{output_file}"
  File.symlink ROOT + '/' + file, output_file
end
