# frozen_string_literal: true

module SlimLint
  # Checks for missing or superfluous spacing before and after dynamic tag output indicators.
  class Linter::DynamicOutputSpacing < Linter
    include LinterRegistry

    PATTERN = "==?['<>]*"

    on [:html, :tag, anything, [], capture(:expr, [:slim, :output, anything, anything])] do |sexp|
      # Fetch original Slim code that contains an element with a control statement.
      expr_line, expr_col = captures[:expr].start
      line = document.source_lines[expr_line - 1][(expr_col - 1)..]

      before_pattern, _ = before_config
      after_pattern, _ = after_config

      report(captures[:expr], line.match?(before_pattern), line.match?(after_pattern))

      # Visit any children of the HTML tag, but don't _revisit_ this Slim output.
      traverse_children(captures[:expr].last)
      :stop
    end

    on [:slim, :output] do |sexp|
      expr_line, expr_col = sexp.start
      line = document.source_lines[expr_line - 1][(expr_col - 1)..]
      after_pattern, _ = after_config

      report(sexp, true, line.match?(after_pattern))
    end

    def report(expr, *results)
      _, before_action = before_config
      _, after_action = after_config

      case results
      when [false, true]
        report_lint(expr, "Please #{before_action} the equals sign")
      when [true, false]
        report_lint(expr, "Please #{after_action} the equals sign")
      when [false, false]
        if before_action[0] == after_action[0]
          report_lint(expr, "Please #{before_action} and after the equals sign")
        else
          report_lint(expr, "Please #{before_action} and #{after_action} the equals sign")
        end
      end
    end

    def before_config
      @before_config ||= case config["space_before"]
      when "never", false, nil
        [/^#{PATTERN}/, "remove spaces before"]
      when "always", "single", true
        [/^ #{PATTERN}/, "use one space before"]
      when "ignore", "any"
        [//, ""]
      else
        raise ArgumentError, "Unknown value for `space_before`; please use 'never', 'always', or 'ignore'"
      end
    end

    def after_config
      @after_config ||= case config["space_after"]
      when "never", false, nil
        [/^ *#{PATTERN}[^ ]/, "remove spaces after"]
      when "always", "single", true
        [/^ *#{PATTERN} [^ ]/, "use one space after"]
      when "ignore", "any"
        [//, ""]
      else
        raise ArgumentError, "Unknown value for `space_after`; please use 'never', 'always', or 'ignore'"
      end
    end
  end
end
