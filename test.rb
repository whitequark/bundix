#!/usr/bin/env ruby

require 'bundler'
#l = Bundler::LockfileParser.new(Bundler.read_file("Gemfile.lock"))

l = Bundler.read_file("Gemfile.lock")


l.gsub!(/^  remote: #{Regexp.escape(".")}/, "  remote: #{"/foo/blah"}")
puts l
