#!/usr/bin/env ruby

require './bin/taskell_file.rb'
require './bin/taskell_recur.rb'

md_filename = ARGV[0] || './taskell.md'
puts "Loading .md file: #{md_filename}..."
taskell_file = TaskellFile.new(md_filename)

puts "Removing entries..."
taskell_file.remove_wnd_entries
taskell_file.remove_done_entries

puts "Writing data file..."
taskell_file.write_file

puts "Done!"
