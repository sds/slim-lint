# frozen_string_literal: true

module SlimLint
  # This linter looks for trailing blank lines and a final newline.
  class Linter::TrailingBlankLines < Linter
    include LinterRegistry

    on_start do |_sexp|
      next if document.source.empty?

      sexp = Sexp.new(:dummy, start: [document.source.lines.size, 0], finish: [document.source.lines.size, 0])
      if !document.source.end_with?("\n")
        report_lint(sexp, "No blank line in the end of file")
      elsif document.source.lines.last.blank?
        report_lint(sexp, "Multiple empty lines in the end of file")
      end
    end
  end
end
