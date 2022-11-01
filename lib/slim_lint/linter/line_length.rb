# frozen_string_literal: true

module SlimLint
  # Checks for lines longer than a maximum number of columns.
  class Linter::LineLength < Linter
    include LinterRegistry

    MSG = "Line is too long. [%d/%d]"

    on_start do |_sexp|
      document.source_lines.each.with_index(1) do |line, i|
        next if line.length <= config["max"]
        sexp = Sexp.new(start: [i, 0], finish: [i, 0])
        report_lint(sexp, format(MSG, line.length, config["max"]))
      end
    end
  end
end
