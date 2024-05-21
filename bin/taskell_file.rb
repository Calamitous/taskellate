require 'securerandom'

# TODO: Change list of tasks from hash to array
# TODO: Decompose data into classes, maybe
#
# Data structure:
# {
#   column_1: [ # Duplicate column names are not allowed
#     "Task 1",
#     "Task 2",
#     "Task 2", # Duplicate task names are OK
#   ],
#   column_2: [
#     "Task 3",
#     "Task 4",
#   ],
# }
class TaskellFile
  attr_reader :data, :filename

  def initialize(filename)
    @filename = filename
    @data = {}
    @current_column = ''
    @current_task_index = -1
    @current_task_text = ''
    self.read_file(@filename)
  end

  def read_file(filename)
    raw_md_file = File.read(filename)
    parse_file(raw_md_file)
  end

  def raw_columns
    @data.keys
  end

  def columns
    @data.keys.map { |c| c.gsub(/^## /, '').chomp }
  end

  def column_counts
    counts = {}
    raw_columns.each do |raw_column|
      counts[raw_column] = @data[raw_column].length
    end

    counts.map{ |k, v| "#{k.gsub(/^## /, '').chomp}: #{v}" }
  end

  def completed_tasks
    @data["## Done\n"]
      .select { |entry| entry !~ /♼/ }
      .map { |entry| entry.split("\n").first }
      .map { |entry| entry.gsub(/\n/, '') }
  end

  def parse_file(raw_md_file)
    puts "Parsing .md file..."

    raw_md_file.each_line do |line|
      # Skip empty lines
      if line.chomp.empty?
        puts "Skipping empty..." if VERBOSE
        next
      end

      # Process column header
      if line =~ /^## /
        @current_column = line
        @current_task_index = -1
        @current_task_text = ''
        puts "Parsing column #{@current_column.chomp}..." if VERBOSE
        @data[@current_column] = []
        next
      end

      # Process task
      if line =~ /^- /
        @current_task_index += 1
        @current_task_text = line.dup
        @data[@current_column][@current_task_index] = @current_task_text
        puts "Parsing task #{@current_column.chomp} -> #{@data[@current_column][@current_task_index]}..." if VERBOSE
        next
      end

      # Process more task text
      if line =~ /^    /
        @current_task_text << line.dup
        @data[@current_column][@current_task_index] = @current_task_text
        puts "Parsing task #{@current_column.chomp} -> #{@data[@current_column][@current_task_index]}..." if VERBOSE
        next
      end

      # TODO: Add processing smarts as needed for descriptions & checklists

      if VERBOSE
        p "Current Column: '#{@current_column}'"
        p "Current Task Index: '#{@current_task_index}'"
        p "Current Task Text: '#{@current_task_text}'"
        p "Col => Task Nil?: '#{@data[@current_column][@current_task_index].nil?}'"
        p "Col => Task Empty?: '#{@data[@current_column][@current_task_index].empty?}'"
        p "Col => Task: '#{@data[@current_column][@current_task_index]}'"
        pp @data
      end

      @data[@current_column] << line
    end

    @data
  end

  def add_entry_from_cron(entry)
    col_key = "## #{entry.column}\n"

    if entry.to_top?
      puts entry.to_md if VERBOSE
      @data[col_key] = @data[col_key].unshift(entry.to_md)
    end

    if entry.to_bottom?
      puts entry.to_md if VERBOSE
      @data[col_key] << entry.to_md
    end
  end

  def remove_wnd_entries
    if @data["## WND/Incomplete\n"].empty?
      puts "No WND/Incomplete items found, skipping..."
    end

    puts "#{@data["## WND/Incomplete\n"].size} WND/Incomplete items found, deleting..."

    @data["## WND/Incomplete\n"] = []
  end

  def remove_done_entries
    if @data["## Done\n"].empty?
      puts "No 'Done' items found, skipping..."
    end

    puts "#{@data["## Done\n"].size} 'Done' items found, deleting..."

    @data["## Done\n"] = []
  end

  def write_file(outfile = @filename)
    File.open(outfile, 'w') do |file|
      @data.keys.each do |column_key|
        file.puts column_key
        file.puts
        @data[column_key].each do |task|
          file.puts task
        end
        file.puts
      end
    end

    # Delete empty last line
    `sed -i '$ d' #{outfile}`
  end
end
