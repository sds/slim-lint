module SlimLint
  # Contains information about a problem or issue with a Slim document.
  class Lint
    # @!attribute filename
    #   @return [String] path to file which the lint applies
    # @!attribute line
    #   @return [String] line number of the file the lint corresponds to
    # @!attribute linter
    #   @return [SlimLint::Linter] linter that reported the lint
    # @!attribute message
    #   @return [String] error/warning message to display to user
    # @!attribute severity
    #   @return [Symbol] whether this lint is a warning or an error
    attr_reader :filename, :line, :linter, :message, :severity

    # Creates a new lint.
    #
    # @param linter [SlimLint::Linter]
    # @param filename [String]
    # @param line [Fixnum]
    # @param message [String]
    # @param severity [Symbol]
    def initialize(linter, filename, line, message, severity = :warning)
      @linter   = linter
      @filename = filename
      @line     = line || 0
      @message  = message
      @severity = severity
    end

    # Return whether this lint has a severity of error.
    #
    # @return [Boolean]
    def error?
      @severity == :error
    end
  end
end
