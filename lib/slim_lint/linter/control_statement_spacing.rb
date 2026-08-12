# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry
    support_autocorrect

    MESSAGE_OUTPUT = 'Please add a space before and after the `=`'
    MESSAGE_CONTROL = 'Please add a space after the `-`'

    # Matches the tag/attribute-shortcut selector, the `=`-based operator
    # (`=`, `==`, `=<`, `=>`, `=<>`, `==<`, `==>`, `==<>`), and the whitespace
    # surrounding the operator, so it can be normalized to a single space on
    # either side without touching the Ruby code that follows.
    OUTPUT_SPACING = /^(\s*)(\S+?)(\s*)(=[=<>]*)(\s*)/

    on [:html, :tag, anything, [],
         [:slim, :output, anything, capture(:ruby, anything)]] do |sexp|
      # Fetch original Slim code that contains an element with a control statement.
      ruby = captures[:ruby]
      line = source_line_for(sexp, /=[=<>]* *#{Regexp.escape(ruby[/[^\n]*/])}/)
      next unless line

      # Remove any Ruby code, because our regexp below must not match inside Ruby.
      line = line.sub(ruby, 'x')

      next if line =~ /[^ ] ==?<?>? [^ ]/

      report_lint(sexp, MESSAGE_OUTPUT,
                  correction: ->(source_line) { source_line.sub(OUTPUT_SPACING, '\1\2 \4 ') })
    end

    on [:slim, :control] do |sexp|
      ruby = sexp[2]
      line = source_line_for(sexp, /- *#{Regexp.escape(ruby[/[^\n]*/])}/)
      next unless line

      next if line =~ /^ *- [^ ]/

      report_lint(sexp, MESSAGE_CONTROL,
                  correction: ->(source_line) { source_line.sub(/^(\s*)-\s*/, '\1- ') })
    end

    private

    # Finds the original Slim source line for the given Sexp.
    #
    # Backslash (`\`) and comma (`,`) line continuations in preceding
    # attributes are collapsed by the Slim parser without emitting a newline,
    # which causes the line number reported for subsequent Sexps to be too low
    # (see https://github.com/sds/slim-lint/issues/201). We compensate by
    # searching forward from the reported line for the line that actually
    # contains the statement, falling back to the reported line otherwise.
    #
    # @param sexp [SlimLint::Sexp]
    # @param pattern [Regexp] matches the source line containing the statement
    # @return [String, nil]
    def source_line_for(sexp, pattern)
      index = sexp.line - 1
      lines = document.source_lines[index..] || []
      lines.find { |line| line =~ pattern } || document.source_lines[index]
    end
  end
end
