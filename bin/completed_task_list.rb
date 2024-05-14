#!/usr/bin/env ruby

require './bin/taskell_file.rb'

VERBOSE = false

md_filename = ARGV[0] || './taskell.md'
puts "Loading .md file: #{md_filename}..." if VERBOSE
taskell_file = TaskellFile.new(md_filename)

taskell_file.completed_tasks.each { |ct| puts ct }
