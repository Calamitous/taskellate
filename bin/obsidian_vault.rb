#!/usr/bin/env ruby

class ObsidianVault
  OBSIDIAN_VAULT_DIR = '~/Documents/FluxxNotes'

  TODO_MARKER_GREP = "\!\!\!"
  TODO_MARKER_REGEX = /!!!/
  TODO_PROCESSED_STAMP = "XxX"

  EXCLUSION_REGEXES = [
    /\/\.obsidian\//,
    /\/\.git\//,
  ]

  attr_reader :files_with_unresolved_todos

  def initialize(obsidian_vault_dir = OBSIDIAN_VAULT_DIR)
    @obsidian_vault_dir = obsidian_vault_dir
    find_files_with_unresolved_todos
  end

  # Return false if the filename matches any of the exclusion regexes
  def is_excluded?(filename)
    !!EXCLUSION_REGEXES.map{ |er| er.match?(filename) }.include?(true)
  end

  def find_files_with_unresolved_todos
    files = `grep -ril "#{TODO_MARKER_GREP}" #{@obsidian_vault_dir}`
    files = files.split("\n")

    @files_with_unresolved_todos = files.reject { |filename| is_excluded?(filename) }
  end

  def fetch_todos
    found_todos = []

    @files_with_unresolved_todos.each do |filename|
      File.readlines(filename).each do |l|
        next unless l =~ TODO_MARKER_REGEX
        todo = {
          title: l.gsub(TODO_MARKER_REGEX, '').gsub(/^\s*-\s*/, '').chomp,
          description: "From \"#{filename.split(/\//).last}\""
        }
        found_todos << todo
      end
    end

    found_todos
  end

  def stamp_todos
    @files_with_unresolved_todos.each do |filename|
      file_text = File.read(filename)
      stamped_file = file_text.gsub(TODO_MARKER_REGEX, TODO_PROCESSED_STAMP)
      File.open(filename, 'w') { |line| line.puts stamped_file }
    end
  end
end
