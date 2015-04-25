module SlimLint
  # Searches for more than an allowed number of consecutive control code
  # statements that could be condensed into a :ruby filter.
  class Linter::ConsecutiveControlStatements < Linter
    include LinterRegistry

    on [:multi] do |sexp|
      Utils.for_consecutive_items(sexp,
                                  ->(nested_sexp) { nested_sexp.match?([:slim, :control]) },
                                  config['max_consecutive'] + 1) do |group|
        report_lint(group.first,
                    "#{group.count} consecutive control statements can be " \
                    'merged into a single `ruby:` filter')
      end
    end
  end
end
