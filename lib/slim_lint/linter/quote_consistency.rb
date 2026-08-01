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
      state = { quote: nil, corrected: [] }
      source_line.scan(/\\.|['"]|[^\\'"]+/).each do |token|
        correct_quote_token(token, state, from, to)
      end
      state[:corrected].join
    end

    def correct_quote_token(token, state, from, to)
      return state[:corrected] << token if token.length > 1 || token.start_with?('\\')

      if state[:quote]
        close_quote_token(token, state, from, to)
      else
        state[:quote] = token
        state[:corrected] << (token == from ? to : token)
      end
    end

    def close_quote_token(token, state, from, to)
      replacement = token == state[:quote] && token == from ? to : token
      state[:corrected] << replacement
      state[:quote] = nil if token == state[:quote]
    end

    def enforced_style
      config['enforced_style']&.to_sym || :single_quotes
    end
  end
end
