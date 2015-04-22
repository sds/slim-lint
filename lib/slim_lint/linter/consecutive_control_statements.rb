module SlimLint
  # Searches for more than an allowed number of consecutive control code
  # statements that could be condensed into a :ruby filter.
  class Linter::ConsecutiveControlStatements < Linter
    include LinterRegistry

    on [:multi] do |sexp|
      Utils.for_consecutive_items(sexp,
                                  method(:code_sexp?),
                                  config['max_consecutive'] + 1) do |group|
        report_lint(group.first,
                    "#{group.count} consecutive control statements can be " \
                    'merged into a single `ruby:` filter')
      end
    end

    private

    # Returns whether the given Sexp is a :code abstraction.
    #
    # @param sexp [SlimLint::Sexp]
    # @return [Boolean]
    def code_sexp?(sexp)
      # TODO: Switch this with a built-in method on the {Sexp} object itself
      sexp.is_a?(Sexp) && sexp.match?([:slim, :control])
    end

    # Whether the given {Sexp} is a newline abstraction.
    #
    # @param sexp [Object]
    # @return [Boolean]
    def newline_sexp?(sexp)
      sexp.is_a?(Sexp) && sexp.first == :newline
    end
  end
end
