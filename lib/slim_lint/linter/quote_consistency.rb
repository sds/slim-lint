# frozen_string_literal: true

module SlimLint
  # Checks for consistent quote usage in HTML attributes
  class Linter::QuoteConsistency < Linter
    include LinterRegistry

    MSG = 'Inconsistent quote style. %s'

    on_start do |_sexp|
      dummy_node = Struct.new(:line)
      document.source_lines.each_with_index do |line, index|
        # Skip lines without any quotes
        next unless line =~ /['"]/

        # Skip comments
        next if line =~ %r{^\s*(/{1,3})}

        # Skip Ruby lines that RuboCop will check
        next if skip_rubocop && line =~ /^\s*[=-]/

        # Find all quoted strings in attributes
        single_quotes = line.scan(/(?<!")'[^"]*'(?!")/)
        double_quotes = line.scan(/(?<!')"[^']*"(?!')/)

        if enforced_style == :single_quotes && double_quotes.any?
          report_lint(dummy_node.new(index + 1),
                      format(MSG, "Use single quotes for attribute values (')"))
        elsif enforced_style == :double_quotes && single_quotes.any?
          report_lint(dummy_node.new(index + 1),
                      format(MSG, 'Use double quotes for attribute values (")'))
        end
      end
    end

    private

    def enforced_style
      config['enforced_style']&.to_sym || :single_quotes
    end

    def skip_rubocop
      config.fetch('skip_rubocop', true)
    end
  end
end
