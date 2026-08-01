# frozen_string_literal: true

module SlimLint
  # Checks for consistent quote usage in HTML attributes
  class Linter::QuoteConsistency < Linter
    include LinterRegistry
    support_autocorrect

    MSG = 'Inconsistent quote style. %s'

    on [:html, :attrs] do |node|
      line = document.source_lines[node.line - 1]

      # Skip lines without any quotes
      next unless line =~ /['"]/

      # Find all quoted strings in attributes (ignoring nested quotes)
      single_quotes = line.scan(/^(?:[^'"]*'[^'"]*'[^'"]*)?(?:[^'"]*)('[^'"]*')/)
      double_quotes = line.scan(/^(?:[^'"]*'[^'"]*'[^'"]*)?(?:[^'"]*)("[^'"]*")/)

      if enforced_style == :single_quotes && double_quotes.any?
        report_lint(node,
                    format(MSG, "Use single quotes for attribute values (')"),
                    correction: ->(source_line) { correct_quotes(source_line, '"', "'") })
      elsif enforced_style == :double_quotes && single_quotes.any?
        report_lint(node,
                    format(MSG, 'Use double quotes for attribute values (")'),
                    correction: ->(source_line) { correct_quotes(source_line, "'", '"') })
      end
    end

    private

    def correct_quotes(source_line, from, to)
      chars = source_line.chars
      corrected = []
      quote = nil
      escaped = false

      chars.each do |char|
        if escaped
          corrected << char
          escaped = false
        elsif char == '\\' && quote
          corrected << char
          escaped = true
        elsif quote.nil? && ["'", '"'].include?(char)
          quote = char
          corrected << (char == from ? to : char)
        elsif quote == char
          corrected << (char == from ? to : char)
          quote = nil
        else
          corrected << char
        end
      end

      corrected.join
    end

    def enforced_style
      config['enforced_style']&.to_sym || :single_quotes
    end
  end
end
