# frozen_string_literal: true

module SlimLint
  # This linter checks for two or more consecutive blank lines
  # and for the first blank line in file.
  class Linter::EmptyLines < Linter
    include LinterRegistry

    on_start do |_sexp|
      was_empty = true
      document.source.lines.each.with_index(1) do |line, i|
        if line.blank?
          if was_empty
            sexp = Sexp.new(start: [i, 0], finish: [i, 0])
            report_lint(sexp, "Extra empty line detected")
          end
          was_empty = true
        else
          was_empty = false
        end
      end
    end
  end
end
