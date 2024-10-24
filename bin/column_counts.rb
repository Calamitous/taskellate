#!/usr/bin/env ruby

require './bin/taskell_file.rb'
require './bin/taskell_recur.rb'

VERBOSE = false

md_filename = ARGV[0] || './taskell.md'
# puts "Loading .md file: #{md_filename}..."
taskell_file = TaskellFile.new(md_filename)

cron_filename = './recurring.cron'
# puts "Loading .cron file: #{cron_filename}..."
cron = TaskellRecur.parse_cron_file_data(cron_filename)

# puts
puts 'Column Counts:'
puts '--------------'
taskell_file.column_counts.each { |cc| puts cc }
puts '--------------'
puts `taskell -i taskell.md`
puts '--------------'
puts "Recurring Tasks: #{cron.weekly_count}"
puts '--------------'
