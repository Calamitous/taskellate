#!/usr/bin/env ruby

require './bin/taskell_entry.rb'
require './bin/taskell_recur.rb'
require './bin/taskell_file.rb'
require './bin/obsidian_vault.rb'

md_filename = ARGV[0] || './taskell.md'
puts "Loading .md file: #{md_filename}..."
taskell_file = TaskellFile.new(md_filename)
vault = ObsidianVault.new

def create_todos(vault, taskell_file)
  entries = vault.fetch_todos.map{ |todo| TaskellEntry.new('IMPORTED', todo[:title], todo[:description]) }

  entries.each do |entry|
    taskell_file.insert_entry(entry)
  end
end

puts "Preparing TODOs from Obsidian..."
create_todos(vault, taskell_file)

puts "Writing taskell data file..."
taskell_file.write_file

puts "Stamping TODOs in Obsidian..."
vault.stamp_todos

puts "Restarting taskell..."
`killall taskell`

puts "Done!"
