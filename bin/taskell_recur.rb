require 'date'

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    self.empty?
  end
end

class TaskellRecur
  attr_reader :entries

  def initialize(entries)
    @entries = entries
  end

  def todays_entries_to_add
    @entries.select(&:valid_today?)
  end

  def self.parse_cron_file_data(filename)
    entries = []

    File.read(filename).lines.each do |line|
      # Skip commented lines
      next if line =~ /^\s*\#/

      # Skip empty lines
      next if line =~ /^$/

      entries << TaskellRecurEntry.parse_cron_entry(line)
    end

    top, bottom = entries.partition { |entry| entry.to_top? }
    entries = top.reverse + bottom
    self.new(entries)
  end

  def weekly_count
    entries.reduce(0) {|agg, entry| entry.days.length + agg }
  end
end

class TaskellRecurEntry
  VALID_REPEATERS = %w{Weekly}
  VALID_DAYS = %w{SU MO TU WE TH FR SA}

  attr_reader :repeater, :days, :column, :position, :title, :description, :subtasks

  def initialize(repeater, days, column, position, title, description, subtasks)
    # TODO: Copy ini files locally and link to .config
    # TODO: Validate title exists
    # TODO: Validate position data (Top/Bottom)
    @repeater = repeater
    @days = days
    @column = column
    @position = position
    @title = title
    @description = description
    @subtasks = subtasks
  end

  def valid_today?
    today = Date.today

    @days.include?(VALID_DAYS[today.wday])
  end

  def to_top?
    position == 'Top'
  end

  def to_bottom?
    position == 'Bottom'
  end

  def to_md
    return ["- #{@title}", description_to_md, subtasks_to_md].join("\n") unless @description.blank? || subtasks.empty?
    return ["- #{@title}", description_to_md].join("\n") unless @description.blank?
    return ["- #{@title}", subtasks_to_md].join("\n") unless subtasks.empty?
    "- #{@title}"
  end

  def self.parse_cron_entry(line)
    unless line.count('|') == 6
      raise "Expected 6 pipes (|), got #{line.count('|')}: #{line}"
    end

    repeater, days, column, position, title, description, subtasks = line.split('|')

    unless VALID_REPEATERS.include?(repeater)
      raise "Repeater must be one of: 'Weekly', got '#{repeater}'"
    end

    days = days.chomp.split('+')

    days.each do |d|
      unless VALID_DAYS.include?(d)
        raise "Day must be one of: 'SU', 'MO', 'TU', 'WE', 'TH', 'FR' 'SA', got #{d}"
      end
    end

    subtasks = (subtasks || '').chomp.split('+')

    # p repeater, days, column, position, title, description, subtasks

    self.new(repeater, days, column, position, title, description, subtasks)
  end

  private

  def description_to_md
    @description.split('+').map { |ds| "    > #{ds}" }
  end

  def subtasks_to_md
    @subtasks.map { |st| "    * [ ] #{st}" }.join("\n")
  end
end


