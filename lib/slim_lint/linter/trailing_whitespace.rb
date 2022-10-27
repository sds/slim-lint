# frozen_string_literal: true

module SlimLint
  # Checks for trailing whitespace.
  class Linter::TrailingWhitespace < Linter
    include LinterRegistry

    on_start do |_sexp|
      dummy = Struct.new(:line)

      document.source_lines.each_with_index do |line, index|
        next unless /\s+$/.match?(line)

        dummy_node = dummy.new(index + 1)
        report_lint(dummy_node, "Line contains trailing whitespace")
      end
    end
  end
end
