# frozen_string_literal: true

RSpec::Matchers.define :report_lint do |options|
  options ||= {}
  count = options[:count]
  expected_line = options[:line]
  expected_cop = options[:cop]

  match do |linter|
    has_lints?(linter, count, expected_line, expected_cop)
  end

  failure_message do |linter|
    count_expectation = case count
    when nil
      "at least one lint"
    when 0
      "no lints"
    when 1
      "a lint"
    else
      "#{count} lints"
    end

    line_expectation = " on line #{expected_line}" if expected_line
    cop_expectation = " of type #{expected_cop}" if expected_cop

    reality = if linter.lints.empty?
      "but no lints were reported"
    else
      [
        "but the following lints were reported:",
        *linter.lints.map do |lint|
          "  * #{lint.message.split(":", 2).first} on line #{lint.line}"
        end
      ].join("\n")
    end

    "expected #{count_expectation} would be reported#{line_expectation}#{cop_expectation}, #{reality}"
  end

  failure_message_when_negated do |linter|
    "expected that a lint would not be reported, but got `#{linter.lints.first.message}`"
  end

  description do
    "report a lint" + (expected_line ? " on line #{expected_line}" : "")
  end

  def has_lints?(linter, count, expected_line, expected_cop)
    correct_count = if count
      linter.lints.count == count
    else
      linter.lints.count > 0
    end

    lints = linter.lints.dup

    correct_line =
      if expected_line.nil?
        true
      elsif count
        lints.all? { |lint| lint.line == expected_line }
      else
        lints.select! { |lint| lint.line == expected_line } if expected_cop
        lints.any? { |lint| lint.line == expected_line }
      end

    correct_cop =
      if expected_cop.nil?
        true
      elsif count
        lints.all? { |lint| lint.message.start_with?("#{expected_cop}:") }
      else
        lints.any? { |lint| lint.message.start_with?("#{expected_cop}:") }
      end

    correct_count && correct_line && correct_cop
  end
end
