# frozen_string_literal: true

module SlimLint
  # Checks for trailing whitespace.
  class Linter::TrailingWhitespace < Linter
    include LinterRegistry

    on_start do |_sexp|
      document.source_lines.each.with_index(1) do |line, lineno|
        next unless /\s+$/.match?(line)

        sexp = Sexp.new(:dummy, start: [lineno, line.rstrip.size], finish: [lineno, line.size])
        report_lint(sexp, "Line contains trailing whitespace")
      end
    end
  end
end
