module SlimLint
  # Searches for control statements with only comments.
  class Linter::CommentControlStatement < Linter
    include LinterRegistry

    on [:slim, :control] do |sexp|
      _, _, code = sexp
      next unless code[/\A\s*#/]

      comment = code[/\A\s*#(.*\z)/, 1]

      report_lint(sexp,
                  "Slim code comments (`/#{comment}`) are preferred over " \
                  "control statement comments (`-##{comment}`)")
    end
  end
end
