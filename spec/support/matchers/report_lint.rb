# frozen_string_literal: true

RSpec::Matchers.define :report_lint do |options|
  options ||= {}
  count = options[:count]
  expected_line = options[:line]
  expected_columns = options[:columns]
  expected_cop = options[:cop]

  match do |linter|
    # pp linter.send(:document).sexp
    has_lints?(linter, options)
  end

  failure_message do |linter|
    count_expectation = case count
    when nil
      "at least one lint"
    when 0
      "no lints"
    when 1
      "a single lint"
    else
      "#{count} lints"
    end

    line_expectation = " on line #{expected_line}" if expected_line
    columns_expectation = ":#{expected_columns.begin}-#{expected_columns.end}" if expected_columns
    cop_expectation = " of type #{expected_cop}" if expected_cop

    reality = if linter.lints.empty?
      "but no lints were reported"
    else
      [
        "but the following lints were reported:",
        *linter.lints.map do |lint|
          "  * [#{lint.cop}] #{lint.message.split(":", 2).first} on line #{lint.line}:#{lint.column}-#{lint.last_column}"
        end
      ].join("\n")
    end

    "expected #{count_expectation} would be reported#{line_expectation}#{columns_expectation}#{cop_expectation}, #{reality}"
  end

  failure_message_when_negated do |linter|
    "expected that a lint would not be reported, but got `#{linter.lints.first.message}`"
  end

  description do
    "report a lint" + (expected_line ? " on line #{expected_line}" : "")
  end

  def has_lints?(linter, options)
    lints = linter.lints.dup

    position_proc =
      if options[:columns]
        proc do |lint|
          lint.line == options[:line] &&
            lint.column == options[:columns].begin &&
            lint.last_column == options[:columns].end
        end
      else
        proc { |lint| lint.line == options[:line] }
      end

    correct_position =
      if options[:line].nil?
        true
      elsif options[:count] || options[:cop]
        lints = lints.select(&position_proc)
      else
        lints.any?(&position_proc)
      end

    correct_cop =
      if options[:cop].nil?
        true
      elsif options[:count]
        lints = lints.select { |lint| lint.cop == options[:cop] }
      else
        lints.any? { |lint| lint.cop == options[:cop] }
      end

    correct_count =
      if options[:count]
        lints.count == options[:count]
      else
        lints.count > 0
      end

    correct_position && correct_cop && correct_count
  end
end
