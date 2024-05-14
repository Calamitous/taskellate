#!/usr/bin/env ruby

# Important: This assumes that hashes maintain entry order

require './taskell_file.rb'
require './taskell_recur.rb'

VERBOSE = false

md_filename = ARGV[0] || './taskell.md'
puts "Loading .md file: #{md_filename}..."
taskell_file = TaskellFile.new(md_filename)

cron_filename = './recurring.cron'
puts "Loading .cron file: #{cron_filename}..."
cron = TaskellRecur.parse_cron_file_data(cron_filename)

cron.todays_entries_to_add.each do |entry|
  p entry.title if VERBOSE
  # TODO: Handle putting entries in specified numeric areas

  taskell_file.add_entry_from_cron(entry)
end

puts "Writing data file..."
taskell_file.write_file
