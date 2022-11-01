# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry

    SINGLE_SPACE_BEFORE_AND_AFTER_RE = /[^ ] ==?<?>? [^ ]/

    MESSAGE = "Please add a space before and after the `=`"

    on [:html, :tag, anything, [], [:slim, :output, anything, capture(:ruby, anything)]] do |sexp|
      # Fetch original Slim code that contains an element with a control statement.
      line = document.source_lines[sexp.line() - 1]

      # Remove any Ruby code, because our regexp below must not match inside Ruby.
      ruby = captures[:ruby].last[1].value
      line = line.sub(ruby, "x")

      next if SINGLE_SPACE_BEFORE_AND_AFTER_RE.match?(line)

      report_lint(sexp, MESSAGE)
    end
  end
end
