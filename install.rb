#!/usr/bin/ruby
require 'erb'
require 'yaml'

ROOT = File.expand_path('../', __FILE__)
HOME = ENV['HOME']
SECRETS = YAML.load_file("#{ROOT}/secrets.yml")


# Parse any ERB files first
Dir['**/**.erb'].each do |file|
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


# Link files into home directory
Dir['**/**.symlink'].each do |file|
  output_file = HOME + '/.' + File.basename(file, '.symlink')

  # Exists? means it's a valid non-symlink file
  if File.exists? output_file
    abort "#{output_file} will be overwritten"
  end

  File.delete output_file if File.symlink? output_file

  puts "Linking #{file} to #{output_file}"
  File.symlink ROOT + '/' + file, output_file
end
