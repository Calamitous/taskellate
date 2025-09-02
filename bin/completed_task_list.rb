#!/usr/bin/env ruby

require './bin/taskell_file.rb'

md_filename = ARGV[0] || './taskell.md'
taskell_file = TaskellFile.new(md_filename)

taskell_file.completed_tasks.each { |ct| puts ct }
