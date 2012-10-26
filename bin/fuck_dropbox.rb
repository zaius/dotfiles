require 'active_support'
require 'active_support/core_ext'

require 'fileutils'
require 'date'
require 'optparse'


# Delete empty folders after this
# find . -name .DS_Store -print0 | xargs -0 rm
# find . -not -path '*/.svn*' -not -path '*/.git*' \( -depth -empty -type d \) -print0 | xargs -0 rmdir
#
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: #{__FILE__} [options] mode"

  # Define the options, and what they do
  options[:print0] = false
  opts.on( '-0', '--print0', 'Output null terminated strings for passing to xargs -0' ) do
    options[:print0] = true
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

mode = ARGV.shift.strip


tag = " (air's conflicted copy 2012-02-23)"
last_sync_date = Date.parse '2012-1-1'
dropbox_sync_date = Date.parse '2012-2-23'

base = Dir.pwd
$stderr.puts "Running in #{base}"


if mode == 'created'
  $stderr.puts "Finding newly created files"
  files = Dir.glob "**/*", File::FNM_DOTMATCH

  files.each do |file|
    next if file.ends_with? '.'

    # Use lstat incase it's a symlink
    stat = File.lstat file

    # puts "#{file} #{File.ctime.to_date} #{dropbox_sync_date}"
    # Make sure it was created by dropbox
    next unless stat.ctime.to_date == dropbox_sync_date
    next unless stat.mtime.to_date < last_sync_date
    if options[:print0]
      print "#{file}\0"
    else
      puts file
    end
  end

  exit

elsif mode == 'conflict'
  $stderr.puts "Finding explicitly conflicted files"
  files = Dir.glob "**/*#{tag}*", File::FNM_DOTMATCH
  files.each do |file|
    original_file = file.gsub tag, ''

    if !File.exists? original_file
      $stderr.puts "Conflicted file exists, but original doesn't - moving: #{original_file}"
      File.rename file, original_file
      next
    end

    # Only bother checking contents if files are the same size
    if File.size(file) == File.size(original_file)
      identical = FileUtils.compare_file file, original_file
      if identical
        puts "Conflicted file identical - deleting: #{original_file}"
        File.delete original_file
        next
      end
    end

    newer = File.mtime(file) > File.mtime(original_file)
    if newer
      puts "Modified file is newer - replacing: #{original_file}"
      File.delete original_file
      File.rename file, original_file
    else
      puts "SHIT: #{original_file}"
    end
  end

else
end
