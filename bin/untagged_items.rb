#!/usr/bin/env ruby

require './bin/taskell_file.rb'

md_filename = ARGV[0] || './taskell.md'
taskell_file = TaskellFile.new(md_filename)

untagged = taskell_file.untagged

if untagged.empty?
  puts "\e[1;32mNo untagged items\e[0m"
else
  untagged.each { |ut| puts ut }
end
