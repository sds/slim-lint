module SlimLint
  class SourceLocation
    attr_accessor :start_line, :start_column, :last_line, :last_column, :line, :column, :length

    def self.merge(start, finish, length:)
      new(
        start_line: start.start_line,
        start_column: start.start_column,
        last_line: finish.start_line,
        last_column: finish.start_column,
        length: length
      )
    end

    def initialize(start_line: nil, start_column: nil, last_line: nil, last_column: nil, length: nil)
      @start_line = @line = start_line
      @start_column = @column = start_column
      @last_line = last_line || @start_line
      @last_column = last_column || @start_column
      @length = length || (start_line == last_line ? last_column - start_column : nil)
    end

    def as_json
      {
        line: line,
        column: column,
        length: length,
        start_line: start_line,
        start_column: start_column,
        last_line: last_line,
        last_column: last_column
      }.compact
    end

    def adjust(line: 0, column: 0)
      self.class.new(
        length: @length,
        start_line: @start_line + line,
        start_column: @start_column + column,
        last_line: @last_line + line,
        last_column: @last_column + column
      )
    end
  end
end
