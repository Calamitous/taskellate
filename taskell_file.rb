require 'securerandom'

class TaskellFile
  attr_reader :data, :filename

  def initialize(filename)
    @filename = filename
    @data = {}
    @current_column = ''
    @current_task = nil
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
      .select{ |entry| entry !~ /♼/ }
      .map(&:first)
      .map { |entry| entry.gsub(/\n/, '') }
  end

  def parse_file(raw_md_file)
    puts "Parsing .md file..."

    raw_md_file.each_line do |line|
      if line.empty? || /^\n$/.match?(line)
        puts "Skipping empty..." if VERBOSE
        next
      end

      if line =~ /^## /
        @current_column = line
        puts "Parsing column #{@current_column.chomp}..." if VERBOSE
        @data[@current_column] = {}
        next
      end

      if line =~ /^- /
        @current_task = line
        puts "Parsing task #{@current_column.chomp} -> #{@current_task.chomp}..." if VERBOSE
        @data[@current_column][@current_task] = @current_task.dup
        next
      end

      if VERBOSE
        p "Current Column: '#{@current_column}'"
        p "Current Task: '#{@current_task}'"
        p "Col => Task Nil?: '#{@data[@current_column][@current_task].nil?}'"
        p "Col => Task: '#{@data[@current_column][@current_task]}'"
        pp @data
      end
      @data[@current_column][@current_task] << line
    end

    @data
  end

  def add_entry_from_cron(entry)
    col_key = "## #{entry.column}\n"

    if entry.to_top?
      @data[col_key] = Hash[@data[col_key].to_a.unshift([SecureRandom.uuid, entry.to_md])]
    end

    if entry.to_bottom?
      @data[col_key] = Hash[@data[col_key].to_a.push([SecureRandom.uuid, entry.to_md])]
    end
  end

  def write_file()
    File.open(@filename, 'w') do |file|
      @data.keys.each do |column_key|
        file.puts column_key
        file.puts
        @data[column_key].keys.each do |task_key|
          file.puts @data[column_key][task_key]
        end
        file.puts
      end
    end

    # Delete empty last line
    `sed -i '$ d' #{filename}`
  end

end


