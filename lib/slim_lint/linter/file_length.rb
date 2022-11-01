# frozen_string_literal: true

module SlimLint
  # Checks for file longer than a maximum number of lines.
  class Linter::FileLength < Linter
    include LinterRegistry

    MSG = "File is too long. [%d/%d]"

    on_start do |_sexp|
      count = document.source_lines.size
      if count > config["max"]
        sexp = Sexp.new(start: [1, 0], finish: [1, 0])
        report_lint(sexp, format(MSG, count, config["max"]))
      end
    end
  end
end
