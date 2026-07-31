# frozen_string_literal: true

module SlimLint
  # Searches for tags with uppercase characters.
  class Linter::TagCase < Linter
    include LinterRegistry
    support_autocorrect

    on [:html, :tag] do |sexp|
      _, _, name = sexp
      next unless name[/[A-Z]/]

      report_lint(sexp, "Tag `#{name}` should be written as `#{name.downcase}`",
                  correction: ->(line) {
                    line.sub(/\b#{Regexp.escape(name.to_s)}\b/, name.downcase)
                  })
    end
  end
end
