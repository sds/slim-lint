# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry

    MESSAGES = {
      before: 'Please add a space before the `=` only'.freeze,
      after: 'Please add a space after the `=` only'.freeze,
      both: 'Please add a space before and after the `=`'.freeze,
      none: 'Please remove spaces before and after the `=`'.freeze,
    }
    STYLES = {
      before: /[^ ] ==?<?>?[^ =<>]/,
      after: /[^ =]==?<?>? [^ ]/,
      both: /[^ ] ==?<?>? [^ ]/,
      none: /[^ =]==?<?>?[^ =<>]/
    }

    on [:html, :tag, anything, [],
         [:slim, :output, anything, capture(:ruby, anything)]] do |sexp|
      style = config.fetch('style', 'both').to_sym

      # Fetch original Slim code that contains an element with a control statement.
      line = document.source_lines[sexp.line() - 1]

      # Remove any Ruby code, because our regexp below must not match inside Ruby.
      ruby = captures[:ruby]
      line = line.sub(ruby, 'x')

      next if line =~ STYLES[style]

      report_lint(sexp, MESSAGES[style])
    end
  end
end
