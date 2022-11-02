# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after control statements.
  class Linter::ControlStatementSpacing < Linter
    include LinterRegistry

    on [:slim, :control] do |sexp|
      expr = sexp.last[0]
      expr_line, expr_col = sexp.start
      line = document.source_lines[expr_line - 1][(expr_col - 1)..]
      after_pattern, after_action = after_config

      unless line.match?(after_pattern)
        report_lint(expr, "Please #{after_action} the dash")
      end
    end

    def after_config
      @after_config ||= case config["space_after"]
      when "never", false, nil
        [/^ *-#?[^# ]/, "remove spaces after"]
      when "always", "single", true
        [/^ *-#? [^ ]/, "use one space after"]
      when "ignore", "any"
        [//, ""]
      else
        raise ArgumentError, "Unknown value for `space_after`; please use 'never' or 'always'"
      end
    end
  end
end
