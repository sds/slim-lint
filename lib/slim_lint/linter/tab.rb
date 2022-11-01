# frozen_string_literal: true

module SlimLint
  # Searches for tab indentation
  class Linter::Tab < Linter
    include LinterRegistry

    TAB_RE = /^( *)[\t ]*\t/
    MSG = "Tab detected"

    on_start do |_sexp|
      document.source_lines.each.with_index(1) do |line, lineno|
        next unless TAB_RE.match?(line)

        sexp = Sexp.new(:dummy, start: [lineno, 0], finish: [lineno, ($` ? $`.size : 0)])
        report_lint(sexp, MSG)
      end
    end
  end
end
