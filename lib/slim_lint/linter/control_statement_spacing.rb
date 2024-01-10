# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry

    MESSAGE = 'Please add a space before and after the `=`'

    on [:html, :tag, anything, [],
         [:slim, :output, anything, capture(:ruby, anything)]] do |sexp|
      # Process original slim code so that multi-line attributes become single line.
      # And store the correction line count
      source = merge_multiline_attributes(document.source_lines)

      # Fetch processed Slim code that contains an element with a control statement.
      line = source[sexp.line - 1][:line]
      # Apply correction to the line count.
      sexp.line += source[sexp.line - 1][:line_count]

      # Remove any Ruby code, because our regexp below must not match inside Ruby.
      ruby = captures[:ruby]
      line = line.sub(ruby, 'x')

      next if line =~ /[^ ] ==?<?>? [^ ]/

      report_lint(sexp, MESSAGE)
    end

    private

    def merge_multiline_attributes(source_lines)
      result = []
      memo = ''
      correction_line_count = 0

      source_lines.each do |line|
        memo += line.chomp('\\')

        # Lines ending in a backslash are concatenated with the next line
        # And count the number of lines to correct the sexp line count.
        if line.match?(/\\$/)
          correction_line_count += 1
          next
        end

        # Add merged rows and correction line count to the result and reset the memo
        result << { line: memo, line_count: correction_line_count }
        memo = ''
      end
      result
    end
  end
end
