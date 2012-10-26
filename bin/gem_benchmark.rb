#!/usr/local/bin/ruby

require 'benchmark'
require 'bundler'

REGEXPS = [
  /^no such file to load -- (.+)$/i,
  /^Missing \w+ (?:file\s*)?([^\s]+.rb)$/i,
  /^Missing API definition file in (.+)$/i,
  /^cannot load such file -- (.+)$/i,
]

def pull(dep)
  begin
    Array(dep.autorequire || dep.name).each do |file|
      required_file = file
      Kernel.require file
    end
  rescue LoadError => e
    if dep.autorequire.nil? && dep.name.include?('-')
      begin
        namespaced_file = dep.name.gsub('-', '/')
        Kernel.require namespaced_file
      rescue LoadError
        REGEXPS.find { |r| r =~ e.message }
        raise if dep.autorequire || $1.gsub('-', '/') != namespaced_file
      end
    else
      REGEXPS.find { |r| r =~ e.message }
      raise if dep.autorequire || $1 != required_file
    end
  end
end

require 'rails/all'

$VERBOSE = nil

Benchmark.bm do |x|
  Bundler.setup.dependencies.each do |dependency|
    x.report(dependency.name[0..20].ljust(21)) do
      pull(dependency)
    end
  end
end

