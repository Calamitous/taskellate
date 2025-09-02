require './bin/taskell_recur.rb'

class TaskellEntry
  attr_reader :column, :title, :description, :subtasks

  def initialize(column, title, description, subtasks = [])
    @column = column
    @title = title
    @description = description
    @subtasks = []
    TaskellRecurEntry.new(nil, nil, @column, 'Top', @title, @description, [])
  end

  def description_to_md
    @description.split('+').map { |ds| "    > #{ds}" }
  end

  def subtasks_to_md
    @subtasks.map { |st| "    * [ ] #{st}" }.join("\n")
  end

  def to_md
    return ["- #{@title}", description_to_md, subtasks_to_md].join("\n") unless @description.blank? || @subtasks.empty?
    return ["- #{@title}", description_to_md].join("\n") unless @description.blank?
    return ["- #{@title}", subtasks_to_md].join("\n") unless @subtasks.empty?
    "- #{@title}"
  end

  def to_s
    "Column: #{@column}\n  Title: #{@title}\n  Description: #{@description}"
  end
end
