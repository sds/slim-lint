# frozen_string_literal: true

module SlimLint
  # Checks for unnecessary uses of the `div` tag where a class name or ID
  # already implies a div.
  class Linter::RedundantDiv < Linter
    include LinterRegistry

    SHORTCUT_ATTRS = %w[id class]
    MESSAGE = "`div` is redundant when %s attribute shortcut is present"

    on [:html, :tag, "div", capture(:attrs, [:html, :attrs]), anything] do |sexp|
      _, _, name, value = captures[:attrs][2]
      next unless name
      next unless value[0] == :static
      next unless SHORTCUT_ATTRS.include?(name.value)

      report_lint(sexp[2], MESSAGE % name)
    end
  end
end
