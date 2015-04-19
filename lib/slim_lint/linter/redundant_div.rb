module SlimLint
  # Checks for unnecessary uses of the `div` tag where a class name or ID
  # already implies a div.
  class Linter::RedundantDiv < Linter
    include LinterRegistry

    MESSAGE = '`div` is redundant when %s attribute shortcut is present'

    on [:html, :tag, 'div', [:html, :attrs, [:html, :attr, 'class', [:static]]]] do |sexp|
      report_lint(sexp, MESSAGE % 'class')
    end

    on [:html, :tag, 'div', [:html, :attrs, [:html, :attr, 'id', [:static]]]] do |sexp|
      report_lint(sexp, MESSAGE % 'id')
    end
  end
end
