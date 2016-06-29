module SlimLint::Filters
  # Traverses a Temple S-expression (that has already been converted to
  # {SlimLint::Sexp} instances) and annotates them with line numbers.
  #
  # This is a hack that allows us to access line information directly from the
  # S-expressions, which makes a lot of other tasks easier.
  class InjectLineNumbers < Temple::Filter
    # {Sexp} representing a newline.
    NEWLINE_SEXP = SlimLint::Sexp.new([:newline])

    # Annotates the given {SlimLint::Sexp} with line number information.
    #
    # @param sexp [SlimLint::Sexp]
    # @return [SlimLint::Sexp]
    def call(sexp)
      @line_number = 1
      traverse(sexp)
      sexp
    end

    private

    # Traverses an {Sexp}, annotating it with line numbers by searching for
    # newline abstractions within it and "\n" inside the value of SlimLint::Atom
    # object.
    #
    # @param sexp [SlimLint::Sexp]
    def traverse(sexp)
      sexp.line = @line_number

      if sexp == NEWLINE_SEXP
        @line_number += 1
        return
      end

      sexp.each do |nested_sexp|
        @line_number += nested_sexp.lines if nested_sexp.is_a?(SlimLint::Atom)
        traverse(nested_sexp) if nested_sexp.is_a?(SlimLint::Sexp)
      end
    end
  end
end
