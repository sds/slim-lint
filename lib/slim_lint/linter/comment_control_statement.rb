# frozen_string_literal: true

module SlimLint
  # Searches for control statements with only comments.
  class Linter::CommentControlStatement < Linter
    include LinterRegistry

    RUBOCOP_CONTROL_COMMENT_RE = /^\s*(rubocop|standard):\w+/
    TEMPLATE_DEPENDENCY_CONTROL_COMMENT_RE = /^\s*Template Dependency:/

    on [:slim, :control] do |sexp|
      _, _, code = sexp
      next unless code.last[1][/\A\s*#/]

      comment = code.last[1][/\A\s*#(.*\z)/, 1]

      next if RUBOCOP_CONTROL_COMMENT_RE.match?(comment)
      next if TEMPLATE_DEPENDENCY_CONTROL_COMMENT_RE.match?(comment)

      msg =
        "Slim code comments (`/#{comment}`) are preferred over " \
        "control statement comments (`-##{comment}`)"
      report_lint(sexp, msg)
    end
  end
end
