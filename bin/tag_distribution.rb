#!/usr/bin/env ruby

require './bin/taskell_file.rb'

md_filename = ARGV[0] || './taskell.md'
taskell_file = TaskellFile.new(md_filename)

tag_dist = taskell_file.completed_tag_distribution
max_width = tag_dist.keys.reduce(0) { |agg, tag| [tag.length, agg].max }

tag_dist.each { |k, v| puts "#{k}:#{' ' * (max_width - k.length + 2)}#{v}" }

